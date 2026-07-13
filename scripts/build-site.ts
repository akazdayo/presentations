import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  artifactPath,
  buildPresentationForSite,
  presentations,
  repositoryRoot,
  type Presentation,
} from "./lib/presentations";

const site = join(repositoryRoot, "_site");
const flakeRef = process.env.FLAKE_REF ?? `path:${repositoryRoot}`;
const pagesBasePath = (process.env.PAGES_BASE_PATH ?? "").replace(/\/+$/, "");

rmSync(site, { force: true, recursive: true });
mkdirSync(site, { recursive: true });

for (const presentation of presentations) {
  console.log(`Building ${presentation.kind}: ${presentation.title}`);
  buildPresentationForSite(presentation, {
    flakeRef,
    outputDirectory: site,
    pagesBasePath,
  });
}

const missing = presentations
  .map(artifactPath)
  .filter((path) => !existsSync(join(site, path)));

if (missing.length > 0) {
  throw new Error(`Missing site artifacts:\n${missing.join("\n")}`);
}

function indexLink(presentation: Presentation): string {
  const path = artifactPath(presentation);
  const linkPath =
    presentation.kind === "typst" ? path : `${presentation.route}/`;
  const format =
    presentation.kind === "typst" ? "Typst PDF" : `${presentation.kind} Web`;
  return `- [${presentation.date} — ${presentation.title}（${format}）](./${linkPath})`;
}

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
