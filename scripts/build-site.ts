import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import {
  artifactPath,
  buildPresentationForSite,
  presentationIndex,
  presentations,
  repositoryRoot,
  type Presentation,
} from "./lib/presentations";

const site = join(repositoryRoot, "_site");
const pagesBasePath = (process.env.PAGES_BASE_PATH ?? "").replace(/\/+$/, "");
const siteBaseUrl = (
  process.env.PAGES_BASE_URL ?? "https://akazdayo.github.io/presentations"
).replace(/\/+$/, "");
rmSync(site, { force: true, recursive: true });
mkdirSync(site, { recursive: true });
for (const presentation of presentations) {
  console.log(`Building ${presentation.kind}: ${presentation.title}`);
  buildPresentationForSite(presentation, site, pagesBasePath);
}

function escapeHtml(text: string): string {
  return text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function indexLink(presentation: Presentation): string {
  const path = artifactPath(presentation);
  const linkPath =
    presentation.kind === "typst" ? path : `${presentation.route}/`;
  const format =
    presentation.kind === "typst" ? "Typst PDF" : `${presentation.kind} Web`;
  return `<li><a href="./${linkPath}">${escapeHtml(presentation.date)} — ${escapeHtml(presentation.title)}（${format}）</a></li>`;
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

verifyArtifacts(presentations);
writeIndex();
