import {
  cpSync,
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";
import { discoverPresentations } from "./presentations";

export type Template = "slidev" | "marp" | "typst-poster";

export interface NewPresentation {
  template: Template;
  name: string;
  title: string;
  date: string;
}

export function createPresentation(
  root: string,
  input: NewPresentation,
): string {
  const { template, name, title, date } = input;
  if (!new Set(["slidev", "marp", "typst-poster"]).has(template)) {
    throw new Error("形式が不正です");
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(name)) {
    throw new Error(
      "ディレクトリ名は小文字の英数字とハイフンで指定してください",
    );
  }
  if (!title.trim() || /[\r\n\x00-\x1f]/.test(title)) {
    throw new Error("タイトルは改行を含まない文字列で指定してください");
  }
  const parsed = new Date(`${date}T00:00:00Z`);
  if (
    !/^\d{4}-\d{2}-\d{2}$/.test(date) ||
    Number.isNaN(parsed.getTime()) ||
    parsed.toISOString().slice(0, 10) !== date
  ) {
    throw new Error("発表日は YYYY-MM-DD 形式の存在する日付で指定してください");
  }
  if (discoverPresentations(root).some((item) => item.name === name)) {
    throw new Error(`資料名 ${name} は既に使われています`);
  }
  const directory = join(root, date.slice(0, 4), name);
  if (existsSync(directory)) throw new Error(`${directory} は既に存在します`);
  const source = join(root, "templates", template);
  if (!existsSync(source))
    throw new Error(`テンプレートが見つかりません: ${source}`);
  mkdirSync(join(root, date.slice(0, 4)), { recursive: true });
  // mkdir without recursive prevents overwriting an existing project.
  mkdirSync(directory);
  const content =
    template === "slidev"
      ? join(directory, "slides")
      : template === "typst-poster"
        ? join(directory, "poster")
        : directory;
  cpSync(source, content, {
    recursive: true,
    force: false,
    errorOnExist: true,
  });
  writeFileSync(
    join(directory, "presentation.json"),
    `${JSON.stringify({ date, title }, null, 2)}\n`,
  );
  if (template === "typst-poster") {
    const path = join(content, "main.typ");
    const text = readFileSync(path, "utf8").replace(
      '#text(size: 42pt, weight: "bold")[Poster title]',
      `#text(${JSON.stringify(title)}, size: 42pt, weight: "bold")`,
    );
    writeFileSync(path, text);
  } else {
    const path = join(content, "package.json");
    const pkg = JSON.parse(readFileSync(path, "utf8"));
    pkg.name = name;
    writeFileSync(path, `${JSON.stringify(pkg, null, 2)}\n`);
    const slidesPath = join(content, "slides.md");
    const heading = title.replace(/[\\`*_{}\[\]<>]/g, "\\$&");
    let slides = readFileSync(slidesPath, "utf8");
    if (template === "slidev")
      slides = slides.replace(
        "title: Presentation title",
        `title: ${JSON.stringify(title)}`,
      );
    slides = slides.replace("# Presentation title", `# ${heading}`);
    writeFileSync(slidesPath, slides);
  }
  return directory;
}
