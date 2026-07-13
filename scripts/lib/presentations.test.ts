import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  artifactPath,
  discoverPresentations,
  findPresentation,
  presentationMatrix,
  placeholderDate,
  placeholderTitle,
  presentationBackends,
  presentations,
  routeBase,
} from "./presentations";

describe("presentation catalog", () => {
  test("uses unique catalog names", () => {
    const names = presentations.map(({ name }) => name);
    expect(new Set(names).size).toBe(names.length);
  });

  test("registers a backend for every format", () => {
    for (const presentation of presentations) {
      expect(presentationBackends[presentation.kind]).toBeDefined();
    }
  });

  test("resolves presentations by name", () => {
    expect(findPresentation("nix-lt").kind).toBe("marp");
    expect(() => findPresentation("missing")).toThrow("Unknown presentation");
  });

  test("maps web and Typst presentations to their site artifacts", () => {
    expect(artifactPath(findPresentation("nix-lt"))).toBe(
      "2026/nix-lt/index.html",
    );
    expect(artifactPath(findPresentation("post-2603"))).toBe(
      "2026/post-2603/poster/poster.pdf",
    );
  });

  test("generates the GitHub Actions matrix from the catalog", () => {
    const matrix = presentationMatrix();

    expect(matrix.include.map(({ presentation }) => presentation)).toEqual(
      presentations.map(({ name }) => name),
    );
    for (const [index, entry] of matrix.include.entries()) {
      const presentation = presentations[index];
      expect(entry.output).toBe(presentation.route);
      expect(entry.source).toBe(
        presentation.route.split("/").slice(0, 2).join("/"),
      );
      expect(entry.kind).toBe(
        presentation.kind === "typst" ? "typst" : "web",
      );
    }
  });

  test("builds normalized GitHub Pages base paths", () => {
    expect(routeBase("2026/example/slides", "/presentations/")).toBe(
      "/presentations/2026/example/slides/",
    );
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
