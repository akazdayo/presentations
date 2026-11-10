import { describe, expect, test } from "bun:test";
import { cpSync, existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createPresentation, type Template } from "./create-presentation";
import { discoverPresentations, repositoryRoot } from "./presentations";

describe("creating presentations", () => {
  test("creates discoverable projects with their title and metadata", () => {
    const root = mkdtempSync(join(tmpdir(), "presentations-create-"));
    try {
      cpSync(join(repositoryRoot, "templates"), join(root, "templates"), {
        recursive: true,
      });
      for (const template of ["slidev", "marp", "typst-poster"] as Template[]) {
        const path = createPresentation(root, {
          template,
          name: template,
          title: 'タイトル: "テスト"',
          date: "2027-02-03",
        });
        expect(
          JSON.parse(readFileSync(join(path, "presentation.json"), "utf8")),
        ).toEqual({ title: 'タイトル: "テスト"', date: "2027-02-03" });
        const source =
          template === "slidev"
            ? join(path, "slides", "slides.md")
            : template === "marp"
              ? join(path, "slides.md")
              : join(path, "poster", "main.typ");
        expect(readFileSync(source, "utf8")).toContain("タイトル:");
      }
      expect(
        discoverPresentations(root)
          .map(({ name }) => name)
          .sort(),
      ).toEqual(["marp", "slidev", "typst-poster"]);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  test("rejects invalid data and duplicate names without overwriting", () => {
    const root = mkdtempSync(join(tmpdir(), "presentations-create-"));
    try {
      cpSync(join(repositoryRoot, "templates"), join(root, "templates"), {
        recursive: true,
      });
      const input = {
        template: "marp" as const,
        name: "example",
        title: "Example",
        date: "2027-01-01",
      };
      expect(() =>
        createPresentation(root, { ...input, name: "../bad" }),
      ).toThrow();
      expect(() =>
        createPresentation(root, { ...input, date: "2027-02-29" }),
      ).toThrow();
      const path = createPresentation(root, input);
      expect(() =>
        createPresentation(root, { ...input, date: "2028-01-01" }),
      ).toThrow();
      expect(existsSync(join(path, "slides.md"))).toBe(true);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
});
