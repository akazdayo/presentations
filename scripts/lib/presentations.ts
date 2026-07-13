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

export interface SiteBuildOptions {
  outputDirectory: string;
  pagesBasePath: string;
  flakeRef: string;
}

/** A format-specific implementation behind the common presentation commands. */
export interface PresentationBackend<
  TPresentation extends Presentation = Presentation,
> {
  dev?(presentation: TPresentation): void;
  build(presentation: TPresentation): void;
  buildForSite(presentation: TPresentation, options: SiteBuildOptions): void;
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

function installAndRun(presentation: WebPresentation, args: string[]): void {
  const cwd = sourceDirectory(presentation);
  run("bun", ["install", "--frozen-lockfile", "--ignore-scripts"], cwd);
  run("bun", args, cwd);
}

const slidevBackend: PresentationBackend<
  Extract<Presentation, { kind: "slidev" }>
> = {
  dev(presentation) {
    installAndRun(presentation, ["run", "dev"]);
  },
  build(presentation) {
    installAndRun(presentation, ["run", "build"]);
  },
  buildForSite(presentation, options) {
    mkdirSync(options.outputDirectory, { recursive: true });
    installAndRun(presentation, [
      "run",
      "build",
      "--",
      "--out",
      options.outputDirectory,
      "--base",
      routeBase(presentation.route, options.pagesBasePath),
      "--router-mode",
      "hash",
    ]);
  },
};

const marpBackend: PresentationBackend<
  Extract<Presentation, { kind: "marp" }>
> = {
  dev(presentation) {
    installAndRun(presentation, ["run", "dev"]);
  },
  build(presentation) {
    installAndRun(presentation, ["run", "build"]);
  },
  buildForSite(presentation, options) {
    mkdirSync(options.outputDirectory, { recursive: true });
    installAndRun(presentation, [
      "run",
      "build",
      "--",
      "--output",
      join(options.outputDirectory, "index.html"),
    ]);
  },
};

const typstBackend: PresentationBackend<TypstPresentation> = {
  build(presentation) {
    run(
      "nix",
      [
        "run",
        `path:.#build-${presentation.target}`,
        "--",
        join(repositoryRoot, artifactPath(presentation)),
      ],
      repositoryRoot,
    );
  },
  buildForSite(presentation, options) {
    mkdirSync(options.outputDirectory, { recursive: true });
    run(
      "nix",
      [
        "run",
        `${options.flakeRef}#build-${presentation.target}`,
        "--",
        join(options.outputDirectory, "poster.pdf"),
      ],
      repositoryRoot,
    );
  },
};

export const presentationBackends = {
  slidev: slidevBackend,
  marp: marpBackend,
  typst: typstBackend,
};

export function findPresentation(name: string): Presentation {
  const presentation = presentations.find(
    (candidate) => candidate.name === name,
  );
  if (presentation) return presentation;

  throw new Error(
    `Unknown presentation: ${name}\nAvailable presentations:\n${presentations
      .map((candidate) => `  ${candidate.name}`)
      .join("\n")}`,
  );
}

export function devPresentation(presentation: Presentation): void {
  if (presentation.kind === "typst") {
    throw new Error(
      `Development mode is not supported for ${presentation.name} (Typst)`,
    );
  }

  presentationBackends[presentation.kind].dev?.(presentation);
}

export function buildPresentation(presentation: Presentation): void {
  switch (presentation.kind) {
    case "slidev":
      return presentationBackends.slidev.build(presentation);
    case "marp":
      return presentationBackends.marp.build(presentation);
    case "typst":
      return presentationBackends.typst.build(presentation);
  }
}

export function buildPresentationForSite(
  presentation: Presentation,
  options: SiteBuildOptions,
): void {
  const siteOptions = {
    ...options,
    outputDirectory: join(options.outputDirectory, presentation.route),
  };

  switch (presentation.kind) {
    case "slidev":
      return presentationBackends.slidev.buildForSite(
        presentation,
        siteOptions,
      );
    case "marp":
      return presentationBackends.marp.buildForSite(presentation, siteOptions);
    case "typst":
      return presentationBackends.typst.buildForSite(presentation, siteOptions);
  }
}

export function artifactPath(presentation: Presentation): string {
  return presentation.kind === "typst"
    ? `${presentation.route}/poster.pdf`
    : `${presentation.route}/index.html`;
}
