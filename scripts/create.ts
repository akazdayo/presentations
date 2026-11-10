import { createInterface } from "node:readline/promises";
import { stdin, stdout } from "node:process";
import { join } from "node:path";
import { createPresentation, type Template } from "./lib/create-presentation";
import { repositoryRoot } from "./lib/presentations";

const readline = createInterface({ input: stdin, output: stdout });
try {
  console.log("新しい資料を作成します。\n1. Slidev\n2. Marp\n3. Typst poster");
  const choice = (await readline.question("形式 [1/2/3]: ")).trim();
  const template = (
    { "1": "slidev", "2": "marp", "3": "typst-poster" } as Record<
      string,
      Template
    >
  )[choice];
  if (!template) throw new Error("形式は 1、2、3 のいずれかを選んでください");
  const name = (await readline.question("ディレクトリ名: ")).trim();
  const title = (await readline.question("タイトル: ")).trim();
  const date = (await readline.question("発表日 (YYYY-MM-DD): ")).trim();
  const directory = createPresentation(repositoryRoot, {
    template,
    name,
    title,
    date,
  });
  console.log(`\n作成しました: ${directory}`);
  if (template !== "typst-poster") {
    const source =
      template === "slidev" ? join(directory, "slides") : directory;
    console.log("依存関係をインストールしてロックファイルを作成します...");
    const result = Bun.spawnSync(["bun", "install", "--ignore-scripts"], {
      cwd: source,
      stdin: "inherit",
      stdout: "inherit",
      stderr: "inherit",
    });
    if (!result.success) {
      throw new Error(
        `依存関係のインストールに失敗しました。${source} で bun install --ignore-scripts を再実行してください`,
      );
    }
    console.log(`\ncd ${source}\nbun run dev`);
  } else {
    console.log(
      `\n新しいファイルを git add した後、リポジトリルートで実行してください:\nnix run .#watch-${name}\nnix run .#build-${name}`,
    );
  }
} catch (error) {
  console.error(`エラー: ${error instanceof Error ? error.message : error}`);
  process.exitCode = 1;
} finally {
  readline.close();
}
