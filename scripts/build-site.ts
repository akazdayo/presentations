import {
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";
import {
  affectedPresentations,
  artifactPath,
  buildPresentationForSite,
  findPresentation,
  presentationIndex,
  presentations,
  repositoryRoot,
  type Presentation,
} from "./lib/presentations";

const site = join(repositoryRoot, "_site");
const flakeRef = process.env.FLAKE_REF ?? `path:${repositoryRoot}`;
const pagesBasePath = (process.env.PAGES_BASE_PATH ?? "").replace(/\/+$/, "");
const siteBaseUrl = (
  process.env.PAGES_BASE_URL ?? "https://akazdayo.github.io/presentations"
).replace(/\/+$/, "");
const buildShaPath = join(site, ".build-sha");
const buildInputHashPath = join(site, ".build-input-hash");
const routesPath = join(site, ".presentation-routes.json");

function prepareSite(): void {
  rmSync(site, { force: true, recursive: true });
  mkdirSync(site, { recursive: true });
}

function build(presentation: Presentation): void {
  console.log(`Building ${presentation.kind}: ${presentation.title}`);
  buildPresentationForSite(presentation, {
    flakeRef,
    outputDirectory: site,
    pagesBasePath,
  });
}

function capture(command: string, args: string[]): string | undefined {
  const result = Bun.spawnSync([command, ...args], {
    cwd: repositoryRoot,
    stderr: "inherit",
    stdout: "pipe",
  });
  return result.success ? result.stdout.toString().trim() : undefined;
}

function currentSha(): string {
  const sha = capture("git", ["rev-parse", "HEAD"]);
  if (!sha) throw new Error("Unable to resolve the current Git commit");
  return sha;
}

function incrementalPlan(): Presentation[] {
  if (!existsSync(buildShaPath)) return presentations;

  const baseSha = readFileSync(buildShaPath, "utf8").trim();
  if (!baseSha) return presentations;

  if (existsSync(buildInputHashPath)) {
    const previousBuildInputHash = readFileSync(
      buildInputHashPath,
      "utf8",
    ).trim();
    if (previousBuildInputHash !== buildInputHash()) return presentations;
  }

  const changed = capture("git", [
    "diff",
    "--name-only",
    `${baseSha}..HEAD`,
    "--",
  ]);
  if (changed === undefined) return presentations;

  const selected = affectedPresentations(
    changed.split("\n").filter((path) => path.length > 0),
  );
  const missing = presentations.filter(
    (presentation) => !existsSync(join(site, artifactPath(presentation))),
  );
  return presentations.filter(
    (presentation) =>
      selected.includes(presentation) || missing.includes(presentation),
  );
}

function buildInputHash(): string {
  const hash = capture("git", ["rev-parse", "HEAD:scripts"]);
  if (!hash) throw new Error("Unable to hash site build scripts");
  return hash;
}

function removeStaleRoutes(): void {
  if (!existsSync(routesPath)) return;

  const previousRoutes = JSON.parse(
    readFileSync(routesPath, "utf8"),
  ) as string[];
  const currentRoutes = new Set(
    presentations.map((presentation) => presentation.route),
  );
  for (const route of previousRoutes) {
    if (!currentRoutes.has(route)) {
      rmSync(join(site, route), { force: true, recursive: true });
    }
  }
}

function recordBuildState(): void {
  writeFileSync(buildShaPath, `${currentSha()}\n`);
  writeFileSync(buildInputHashPath, `${buildInputHash()}\n`);
  writeFileSync(
    routesPath,
    `${JSON.stringify(presentations.map((presentation) => presentation.route))}\n`,
  );
}

function buildIncrementally(): void {
  mkdirSync(site, { recursive: true });
  removeStaleRoutes();
  const selected = incrementalPlan();

  for (const presentation of selected) {
    rmSync(join(site, presentation.route), { force: true, recursive: true });
    build(presentation);
  }

  verifyArtifacts(presentations);
  writeIndex();
  recordBuildState();
}

function indexLink(presentation: Presentation): string {
  const path = artifactPath(presentation);
  const linkPath =
    presentation.kind === "typst" ? path : `${presentation.route}/`;
  const format =
    presentation.kind === "typst" ? "Typst PDF" : `${presentation.kind} Web`;
  return `<li><a href="./${linkPath}">${presentation.date} — ${presentation.title}（${format}）</a></li>`;
}

function writeIndex(): void {
  mkdirSync(site, { recursive: true });
  const html = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Presentations</title>
    <style>
      body { max-width: 64rem; margin: 3rem auto; padding: 0 1.5rem; font: 16px/1.6 system-ui, sans-serif; color: #24292f; }
      a { color: #0969da; }
      li { margin: .5rem 0; }
    </style>
  </head>
  <body>
    <h1>Presentations</h1>
    <ul>
${presentations.map((presentation) => `      ${indexLink(presentation)}`).join("\n")}
    </ul>
  </body>
</html>
`;

  writeFileSync(join(site, "index.html"), html);
  writePresentationsJson();
  console.log(`Generated ${join(site, "index.html")}`);
}

function writePresentationsJson(): void {
  const directory = join(site, ".well-known");
  mkdirSync(directory, { recursive: true });
  writeFileSync(
    join(directory, "presentations.json"),
    `${JSON.stringify(presentationIndex(presentations, siteBaseUrl), null, 2)}\n`,
  );
  console.log(`Generated ${join(directory, "presentations.json")}`);
}

function verifyArtifacts(expected: Presentation[]): void {
  const missing = expected
    .map(artifactPath)
    .filter((path) => !existsSync(join(site, path)));

  if (missing.length > 0) {
    throw new Error(`Missing site artifacts:\n${missing.join("\n")}`);
  }
}

const [command, name, ...extraArguments] = Bun.argv.slice(2);

if (extraArguments.length > 0) {
  throw new Error("Usage: build-site.ts [build <name>|index]");
}

switch (command) {
  case undefined:
    prepareSite();
    for (const presentation of presentations) build(presentation);
    verifyArtifacts(presentations);
    writeIndex();
    recordBuildState();
    break;
  case "build": {
    if (!name) throw new Error("Usage: build-site.ts build <name>");
    const presentation = findPresentation(name);
    prepareSite();
    build(presentation);
    verifyArtifacts([presentation]);
    break;
  }
  case "index":
    if (name) throw new Error("Usage: build-site.ts index");
    writeIndex();
    break;
  case "plan": {
    if (name) throw new Error("Usage: build-site.ts plan");
    const selected = incrementalPlan();
    console.log(
      JSON.stringify({
        names: selected.map((presentation) => presentation.name),
        needsNix: selected.some(
          (presentation) => presentation.kind === "typst",
        ),
      }),
    );
    break;
  }
  case "incremental":
    if (name) throw new Error("Usage: build-site.ts incremental");
    buildIncrementally();
    break;
  default:
    throw new Error(
      "Usage: build-site.ts [build <name>|index|plan|incremental]",
    );
}
