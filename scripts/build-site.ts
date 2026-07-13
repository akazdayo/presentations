import {
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";

const root = join(import.meta.dir, "..");
const site = join(root, "_site");
const flakeRef = process.env.FLAKE_REF ?? `path:${root}`;
const pagesBasePath = (process.env.PAGES_BASE_PATH ?? "").replace(/\/+$/, "");

type Presentation =
  | {
      date: string;
      title: string;
      kind: "slidev" | "marp";
      source: string;
      route: string;
    }
  | {
      date: string;
      title: string;
      kind: "typst";
      target: string;
      route: string;
    };

const presentations: Presentation[] = [
  {
    date: "2025-12-19",
    title: "Nostrを一年間使ってみた感想",
    kind: "slidev",
    source: "2025/nostr-one-year/slides",
    route: "2025/nostr-one-year/slides",
  },
  {
    date: "2025-12-20",
    title: "Slidev × スマホClaude Code × Vercel",
    kind: "slidev",
    source: "2025/slidev-mobile-claude/slides",
    route: "2025/slidev-mobile-claude/slides",
  },
  {
    date: "2026-02-13",
    title: "TerraformでNixOSをデプロイする",
    kind: "marp",
    source: "2026/nix-lt",
    route: "2026/nix-lt",
  },
  {
    date: "2026-03",
    title: "単眼カメラを用いたVR向け仮想トラッカーの制作",
    kind: "typst",
    target: "post-2603",
    route: "2026/post-2603/poster",
  },
  {
    date: "2026-03-11",
    title: "私がNixについてやったこと",
    kind: "slidev",
    source: "2026/nix-journey/slides",
    route: "2026/nix-journey/slides",
  },
  {
    date: "2026-05-27",
    title: "TEEを活用したNix Binary Cacheの信頼スコアリング",
    kind: "typst",
    target: "nix-cache-05-27",
    route: "2026/nix-cache-05-27/poster",
  },
  {
    date: "2026-05-30",
    title: "会話の温度計",
    kind: "slidev",
    source: "2026/conversation-thermometer/slides",
    route: "2026/conversation-thermometer/slides",
  },
  {
    date: "2026-06-05",
    title: "Nix Binary CacheとTEE",
    kind: "slidev",
    source: "2026/nix-tee/slides",
    route: "2026/nix-tee/slides",
  },
  {
    date: "2026-06-06",
    title: "NixOSでMinecraftサーバーを構築してみる",
    kind: "slidev",
    source: "2026/nix-minecraft/slides",
    route: "2026/nix-minecraft/slides",
  },
  {
    date: "2026 summer — 1st event",
    title: "SecHack365 テーマ概要（Slidev）",
    kind: "slidev",
    source: "2026/sechack-1st-event",
    route: "2026/sechack-1st-event",
  },
  {
    date: "2026 summer — 2nd event",
    title: "SecHack365 テーマ概要（Typst flyer）",
    kind: "typst",
    target: "sechack-2nd-event",
    route: "2026/sechack-2nd-event/poster",
  },
];

function run(command: string, args: string[], cwd: string): void {
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

function capture(command: string, args: string[], cwd: string): string {
  const result = Bun.spawnSync([command, ...args], {
    cwd,
    stderr: "inherit",
    stdout: "pipe",
  });

  if (!result.success) {
    throw new Error(
      `Command failed (${result.exitCode}): ${command} ${args.join(" ")}`,
    );
  }

  return new TextDecoder().decode(result.stdout).trim();
}

function routeBase(route: string): string {
  return `${pagesBasePath}/${route}/`.replace(/\/+/g, "/");
}

function buildWebPresentation(
  presentation: Extract<Presentation, { kind: "slidev" | "marp" }>,
): void {
  const sourceDir = join(root, presentation.source);
  const outputDir = join(site, presentation.route);
  mkdirSync(outputDir, { recursive: true });

  run("bun", ["install", "--frozen-lockfile", "--ignore-scripts"], sourceDir);

  if (presentation.kind === "slidev") {
    run(
      "bun",
      [
        "run",
        "build",
        "--",
        "--out",
        outputDir,
        "--base",
        routeBase(presentation.route),
      ],
      sourceDir,
    );
    return;
  }

  run(
    "bun",
    ["run", "build", "--", "--output", join(outputDir, "index.html")],
    sourceDir,
  );
}

function findPdf(path: string): string | undefined {
  if (statSync(path).isFile()) {
    return path;
  }

  for (const entry of readdirSync(path)) {
    const found = findPdf(join(path, entry));
    if (found) return found;
  }

  return undefined;
}

function buildTypstPresentation(
  presentation: Extract<Presentation, { kind: "typst" }>,
): void {
  const output = capture(
    "nix",
    [
      "build",
      `${flakeRef}#${presentation.target}`,
      "--no-link",
      "--print-out-paths",
    ],
    root,
  )
    .split("\n")
    .filter(Boolean)
    .at(-1);

  if (!output) {
    throw new Error(
      `No output produced for Typst target: ${presentation.target}`,
    );
  }

  const pdf = findPdf(output);
  if (!pdf) {
    throw new Error(`No PDF produced for Typst target: ${presentation.target}`);
  }

  const destination = join(site, presentation.route, "poster.pdf");
  mkdirSync(join(site, presentation.route), { recursive: true });
  cpSync(pdf, destination);
}

rmSync(site, { force: true, recursive: true });
mkdirSync(site, { recursive: true });

for (const presentation of presentations) {
  console.log(`Building ${presentation.kind}: ${presentation.title}`);
  if (presentation.kind === "typst") {
    buildTypstPresentation(presentation);
  } else {
    buildWebPresentation(presentation);
  }
}

const artifactPath = (presentation: Presentation): string =>
  presentation.kind === "typst"
    ? `${presentation.route}/poster.pdf`
    : `${presentation.route}/index.html`;

const missing = presentations
  .map(artifactPath)
  .filter((path) => !existsSync(join(site, path)));

if (missing.length > 0) {
  throw new Error(`Missing site artifacts:\n${missing.join("\n")}`);
}

const links = presentations
  .map((presentation) => {
    const path = artifactPath(presentation);
    const linkPath =
      presentation.kind === "typst" ? path : presentation.route + "/";
    const format =
      presentation.kind === "typst" ? "Typst PDF" : `${presentation.kind} Web`;
    return `- [${presentation.date} — ${presentation.title}（${format}）](./${linkPath})`;
  })
  .join("\n");

const markdown = `---
layout: default
title: Presentations
---

# Presentations

${links}
`;

writeFileSync(join(site, "index.md"), markdown);
writeFileSync(
  join(site, "_config.yml"),
  "theme: jekyll-theme-primer\ntitle: Presentations\n",
);
console.log(`Generated ${join(site, "index.md")}`);
