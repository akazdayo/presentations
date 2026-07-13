import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  artifactPath,
  buildPresentationForSite,
  findPresentation,
  presentations,
  repositoryRoot,
  type Presentation,
} from "./lib/presentations";

const site = join(repositoryRoot, "_site");
const flakeRef = process.env.FLAKE_REF ?? `path:${repositoryRoot}`;
const pagesBasePath = (process.env.PAGES_BASE_PATH ?? "").replace(/\/+$/, "");

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
  console.log(`Generated ${join(site, "index.html")}`);
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
  default:
    throw new Error("Usage: build-site.ts [build <name>|index]");
}
