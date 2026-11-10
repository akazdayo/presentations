import { existsSync, mkdirSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

export const repositoryRoot = join(import.meta.dir, "../..");

export type PresentationKind = "slidev" | "marp" | "typst";

interface PresentationBase {
  name: string;
  date: string;
  title: string;
  route: string;
}

interface WebPresentationBase extends PresentationBase {
  source: string;
}

export interface SlidevPresentation extends WebPresentationBase {
  kind: "slidev";
}

export interface MarpPresentation extends WebPresentationBase {
  kind: "marp";
}

export type WebPresentation = SlidevPresentation | MarpPresentation;

export interface TypstPresentation extends PresentationBase {
  kind: "typst";
  target: string;
}

export type Presentation =
  | SlidevPresentation
  | MarpPresentation
  | TypstPresentation;

export interface PresentationIndexEntry {
  url: string;
  title: string;
  date: string;
}

interface PresentationMetadata {
  date?: string;
  title?: string;
}

interface PackageJson {
  scripts?: Record<string, string>;
  dependencies?: Record<string, string>;
  devDependencies?: Record<string, string>;
}

export const placeholderDate = "TBD";

export function placeholderTitle(name: string): string {
  return `Untitled (${name})`;
}

function readJson<T>(path: string): T {
  return JSON.parse(readFileSync(path, "utf8")) as T;
}

function readMetadata(directory: string): PresentationMetadata {
  const path = join(directory, "presentation.json");
  return existsSync(path) ? readJson<PresentationMetadata>(path) : {};
}

function detectWebKind(path: string): WebPresentation["kind"] | undefined {
  if (!existsSync(path)) return undefined;

  const packageJson = readJson<PackageJson>(path);
  const dependencies = {
    ...packageJson.dependencies,
    ...packageJson.devDependencies,
  };
  const commands = Object.values(packageJson.scripts ?? {}).join(" ");

  if ("@slidev/cli" in dependencies || /(^|\s)slidev(?:\s|$)/.test(commands)) {
    return "slidev";
  }
  if (
    "@marp-team/marp-cli" in dependencies ||
    /(^|\s)marp(?:\s|$)/.test(commands)
  ) {
    return "marp";
  }
  return undefined;
}

function discoverPresentation(
  root: string,
  year: string,
  name: string,
): Presentation | undefined {
  const directory = join(root, year, name);
  const metadata = readMetadata(directory);
  const common = {
    name,
    date: metadata.date ?? placeholderDate,
    title: metadata.title ?? placeholderTitle(name),
  };
  const sourceCandidates = [
    { path: join(directory, "package.json"), source: `${year}/${name}` },
    {
      path: join(directory, "slides", "package.json"),
      source: `${year}/${name}/slides`,
    },
  ];

  for (const candidate of sourceCandidates) {
    const kind = detectWebKind(candidate.path);
    if (kind) {
      return {
        ...common,
        kind,
        source: candidate.source,
        route: candidate.source,
      };
    }
  }

  if (existsSync(join(directory, "poster", "main.typ"))) {
    return {
      ...common,
      kind: "typst",
      target: name,
      route: `${year}/${name}/poster`,
    };
  }

  return undefined;
}

function dateSortKey(date: string): string {
  const isoDate = /^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?$/.exec(date);
  if (isoDate) {
    const [, year, month = "00", day = "00"] = isoDate;
    return `${year}-${month}-${day}`;
  }

  const year = /^(\d{4})/.exec(date)?.[1];
  return year ? `${year}-99-${date}` : `9999-${date}`;
}

export function discoverPresentations(root = repositoryRoot): Presentation[] {
  return readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && /^\d{4}$/.test(entry.name))
    .flatMap((yearEntry) =>
      readdirSync(join(root, yearEntry.name), { withFileTypes: true })
        .filter((entry) => entry.isDirectory())
        .map((entry) => discoverPresentation(root, yearEntry.name, entry.name))
        .filter((presentation) => presentation !== undefined),
    )
    .sort(
      (left, right) =>
        dateSortKey(left.date).localeCompare(dateSortKey(right.date)) ||
        left.name.localeCompare(right.name),
    );
}

export const presentations = discoverPresentations();

export function run(command: string, args: string[], cwd: string): void {
  const result = Bun.spawnSync([command, ...args], {
    cwd,
    stderr: "inherit",
    stdout: "inherit",
  });

  if (!result.success) {
    throw new Error(
      `Command failed (${result.exitCode}): ${command} ${args.join(" ")}`,
    );
  }
}

function sourceDirectory(presentation: WebPresentation): string {
  return join(repositoryRoot, presentation.source);
}

export function routeBase(route: string, pagesBasePath: string): string {
  return `${pagesBasePath}/${route}/`.replace(/\/+/g, "/");
}

export function presentationIndex(
  catalog: Presentation[] = presentations,
  siteBaseUrl: string,
): PresentationIndexEntry[] {
  const normalizedBaseUrl = siteBaseUrl.replace(/\/+$/, "");

  return catalog.map((presentation) => ({
    url: `${normalizedBaseUrl}/${
      presentation.kind === "typst"
        ? artifactPath(presentation)
        : `${presentation.route}/`
    }`,
    title: presentation.title,
    date: presentation.date,
  }));
}

function installAndRun(presentation: WebPresentation, args: string[]): void {
  const cwd = sourceDirectory(presentation);
  run("bun", ["install", "--frozen-lockfile", "--ignore-scripts"], cwd);
  run("bun", args, cwd);
}

export function buildPresentationForSite(
  presentation: Presentation,
  outputDirectory: string,
  pagesBasePath: string,
): void {
  const output = join(outputDirectory, presentation.route);
  mkdirSync(output, { recursive: true });

  if (presentation.kind === "typst") {
    run(
      "nix",
      [
        "run",
        `.#build-${presentation.target}`,
        "--",
        join(output, "poster.pdf"),
      ],
      repositoryRoot,
    );
    return;
  }

  if (presentation.kind === "slidev") {
    installAndRun(presentation, [
      "run",
      "build",
      "--",
      "--out",
      output,
      "--base",
      routeBase(presentation.route, pagesBasePath),
      "--router-mode",
      "hash",
    ]);
  } else {
    installAndRun(presentation, [
      "run",
      "build",
      "--",
      "--output",
      join(output, "index.html"),
    ]);
  }
}

export function artifactPath(presentation: Presentation): string {
  return presentation.kind === "typst"
    ? `${presentation.route}/poster.pdf`
    : `${presentation.route}/index.html`;
}
