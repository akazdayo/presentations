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
  return `- [${presentation.date} — ${presentation.title}（${format}）](./${linkPath})`;
}

function writeIndex(): void {
  const markdown = `---
layout: default
title: Presentations
---

# Presentations

${presentations.map(indexLink).join("\n")}
`;

  writeFileSync(join(site, "index.md"), markdown);
  writeFileSync(
    join(site, "_config.yml"),
    "theme: jekyll-theme-primer\ntitle: Presentations\n",
  );
  console.log(`Generated ${join(site, "index.md")}`);
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
    prepareSite();
    writeIndex();
    break;
  default:
    throw new Error("Usage: build-site.ts [build <name>|index]");
}
