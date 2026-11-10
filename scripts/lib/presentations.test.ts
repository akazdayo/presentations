import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  artifactPath,
  discoverPresentations,
  presentationIndex,
  placeholderDate,
  placeholderTitle,
  presentations,
  routeBase,
} from "./presentations";

describe("presentation catalog", () => {
  test("uses unique catalog names", () => {
    const names = presentations.map(({ name }) => name);
    expect(new Set(names).size).toBe(names.length);
  });

  test("maps web and Typst presentations to their site artifacts", () => {
    const marp = presentations.find(({ name }) => name === "nix-lt")!;
    const typst = presentations.find(({ name }) => name === "post-2603")!;
    expect(artifactPath(marp)).toBe("2026/nix-lt/index.html");
    expect(artifactPath(typst)).toBe("2026/post-2603/poster/poster.pdf");
  });

  test("builds normalized GitHub Pages base paths", () => {
    expect(routeBase("2026/example/slides", "/presentations/")).toBe(
      "/presentations/2026/example/slides/",
    );
  });

  test("generates public URLs for the presentation index", () => {
    expect(
      presentationIndex(
        [
          presentations.find(({ name }) => name === "nix-lt")!,
          presentations.find(({ name }) => name === "post-2603")!,
        ],
        "https://example.com/presentations/",
      ),
    ).toEqual([
      {
        url: "https://example.com/presentations/2026/nix-lt/",
        title: "TerraformでNixOSをデプロイする",
        date: "2026-02-13",
      },
      {
        url: "https://example.com/presentations/2026/post-2603/poster/poster.pdf",
        title: "単眼カメラを用いたVR向け仮想トラッカーの制作",
        date: "2026-03",
      },
    ]);
  });

  test("discovers a deck without metadata and supplies placeholders", () => {
    const root = mkdtempSync(join(tmpdir(), "presentations-"));
    const slides = join(root, "2027", "new-deck", "slides");

    try {
      mkdirSync(slides, { recursive: true });
      writeFileSync(
        join(slides, "package.json"),
        JSON.stringify({ dependencies: { "@slidev/cli": "latest" } }),
      );

      expect(discoverPresentations(root)).toEqual([
        {
          name: "new-deck",
          date: placeholderDate,
          title: placeholderTitle("new-deck"),
          kind: "slidev",
          source: "2027/new-deck/slides",
          route: "2027/new-deck/slides",
        },
      ]);
    } finally {
      rmSync(root, { force: true, recursive: true });
    }
  });

  test("reads display metadata when presentation.json exists", () => {
    const root = mkdtempSync(join(tmpdir(), "presentations-"));
    const presentation = join(root, "2027", "typst-deck");

    try {
      mkdirSync(join(presentation, "poster"), { recursive: true });
      writeFileSync(join(presentation, "poster", "main.typ"), "Hello");
      writeFileSync(
        join(presentation, "presentation.json"),
        JSON.stringify({ date: "2027-01-02", title: "Generated catalog" }),
      );

      expect(discoverPresentations(root)[0]).toMatchObject({
        name: "typst-deck",
        date: "2027-01-02",
        title: "Generated catalog",
        kind: "typst",
        target: "typst-deck",
      });
    } finally {
      rmSync(root, { force: true, recursive: true });
    }
  });
});
