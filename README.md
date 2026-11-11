# presentations

過去のプレゼンテーション資料をまとめたリポジトリです！Actionsで自動デプロイしてるー
https://akazdayo.github.io/presentations

## 新しい資料の作成

リポジトリルートで次のコマンドを実行すると、形式、名前、タイトル、発表日を
入力して Slidev・Marp・Typst ポスターを作成できます。

```bash
bun run scripts/create.ts
```

発表日の年のディレクトリに作成します。Slidev と Marp は依存関係をインストールし、
`bun.lock` を生成します。Typst の新規ファイルは Git に追加後、Nix から利用できます。
資料名は年をまたいでも一意にしてください。

## Development

Nix を使う場合は、リポジトリルートで `nix develop` を実行します。
Slidev や Marp の資料は各ディレクトリで直接操作します。

Neovim などから Prettier で Slidev を整形する場合は、最初にリポジトリルートで
`npm ci --prefix tools/slidev-prettier` を実行してプラグインをインストールします。
エディターを再起動すると、Slidev 用のパーサーが使われます。

```bash
cd 2026/nix-journey/slides
bun install --frozen-lockfile
bun run dev
bun run build
```

Typst ポスターはリポジトリルートから Typix でビルドします。PDF は各 `poster/poster.pdf` に出力されます。編集時は watch で変更を監視できます。

```bash
nix run .#build-post-2603
nix run .#watch-post-2603
```

Nushell では、リポジトリルートで次を実行すると `nix run .#build-` などの
Tab 補完を使えます。候補は Nix の flake 出力から取得します。

```nu
source scripts/nix-completions.nu
```

この設定は現在の Nushell セッションに適用されます。既存の外部補完がある場合は、
Nix 以外のコマンドと Nix がファイル名補完を求める場合に引き継ぎます。

`nix flake check` は Typst ポスターのビルドと整形状態を検証します。
`bun test scripts/lib/*.test.ts` でカタログと作成処理のテスト、
`nix fmt` でリポジトリ全体の整形を実行できます。

全資料の Web 成果物と索引を生成する場合は、リポジトリルートで実行します。

```bash
bun run scripts/build-site.ts
```

成果物は `_site/` に生成されます。各資料の `presentation.json` に記載した
日付とタイトルを索引と `/.well-known/presentations.json` に使います。
項目がない場合は `TBD` と `Untitled (<name>)` が使われます。
公開 URL のベースは `PAGES_BASE_URL`、Web 資料のサブパスは
`PAGES_BASE_PATH` 環境変数で指定できます。

## GitHub Pages

`.github/workflows/deploy-pages.yml` は `main` への push または手動実行時に、
全資料をソースからビルドして GitHub Pages へデプロイします。
初回のみリポジトリの **Settings → Pages → Build and deployment → Source** を
**GitHub Actions** に設定してください。

## Layout

```text
presentations/
├── 2025/                    # 2025年の発表
├── 2026/                    # 2026年の発表
│   └── <presentation>/
│       ├── slides/          # Slidev（ある場合）
│       ├── poster/          # Typst（ある場合）
│       └── assets/          # 発表全体の共有資産（ある場合）
├── shared/
│   ├── themes/{typst,marp,slidev}/
│   ├── components/{typst,slidev}/
│   ├── logos/
│   └── diagrams/
├── templates/{typst-poster,typst-slides,marp,slidev}/
└── flake.nix
```

各 Slidev プロジェクトは、移行時点の `bun.lock` と個別の `package.json` を保持しています。依存関係は各Slidevプロジェクトのディレクトリで `bun install --frozen-lockfile` を実行してください。

## Migration notes

次の3リポジトリの現行ワークツリー（未コミット変更を含む）から移行しました。

- `/home/akazdayo/programs/LT-slides`
- `/home/akazdayo/programs/sechack/slides`
- `/home/akazdayo/programs/post-2603`

資料本体、画像、ロックファイル、発表用デモは保持しています。`.git`、`.direnv`、`node_modules`、Slidevの `dist`、Typstの生成PDFなど、履歴またはソースから再生成できるものは移行対象外です。
