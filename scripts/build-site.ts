import { existsSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const root = join(import.meta.dir, "..");
const site = join(root, "_site");

const presentations = [
  {
    date: "2025-12-19",
    title: "Nostrを一年間使ってみた感想",
    artifacts: [["Slidev", "2025/nostr-one-year/slides.pdf"]],
  },
  {
    date: "2025-12-20",
    title: "Slidev × スマホClaude Code × Vercel",
    artifacts: [["Slidev", "2025/slidev-mobile-claude/slides.pdf"]],
  },
  {
    date: "2026-02-13",
    title: "TerraformでNixOSをデプロイする",
    artifacts: [["Marp", "2026/nix-lt/slides.pdf"]],
  },
  {
    date: "2026-03",
    title: "単眼カメラを用いたVR向け仮想トラッカーの制作",
    artifacts: [["Typst", "2026/post-2603/poster.pdf"]],
  },
  {
    date: "2026-03-11",
    title: "私がNixについてやったこと",
    artifacts: [["Slidev", "2026/nix-journey/slides.pdf"]],
  },
  {
    date: "2026-05-27",
    title: "TEEを活用したNix Binary Cacheの信頼スコアリング",
    artifacts: [["Typst", "2026/nix-cache-05-27/poster.pdf"]],
  },
  {
    date: "2026-05-30",
    title: "会話の温度計",
    artifacts: [["Slidev", "2026/conversation-thermometer/slides.pdf"]],
  },
  {
    date: "2026-06-05",
    title: "Nix Binary CacheとTEE",
    artifacts: [["Slidev", "2026/nix-tee/slides.pdf"]],
  },
  {
    date: "2026-06-06",
    title: "NixOSでMinecraftサーバーを構築してみる",
    artifacts: [["Slidev", "2026/nix-minecraft/slides.pdf"]],
  },
  {
    date: "2026 summer — 1st event",
    title: "SecHack365 テーマ概要（Slidev）",
    artifacts: [["Slidev", "2026/sechack-1st-event/slides.pdf"]],
  },
  {
    date: "2026 summer — 2nd event",
    title: "SecHack365 テーマ概要（Typst flyer）",
    artifacts: [["Typst", "2026/sechack-2nd-event/poster.pdf"]],
  },
] as const;

const missing = presentations.flatMap((presentation) =>
  presentation.artifacts
    .map(([, path]) => path)
    .filter((path) => !existsSync(join(site, path))),
);

if (missing.length > 0) {
  throw new Error(`Missing PDF artifacts:\n${missing.join("\n")}`);
}

const links = presentations
  .flatMap(({ date, title, artifacts }) =>
    artifacts.map(
      ([format, path]) => `- [${date} — ${title}（${format} PDF）](./${path})`,
    ),
  )
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
