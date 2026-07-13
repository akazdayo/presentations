# presentations

過去の発表資料を、年・発表単位でまとめた monorepo です。Slidev、Marp、Typst の資料と、発表に必要な画像・デモコード・ロックファイルを保存しています。

## Catalog

| Date                    | Presentation                                    | Format | Source                                                            |
| ----------------------- | ----------------------------------------------- | ------ | ----------------------------------------------------------------- |
| 2025-12-19              | Nostrを一年間使ってみた感想                     | Slidev | [`2025/nostr-one-year`](2025/nostr-one-year/)                     |
| 2025-12-20              | Slidev × スマホClaude Code × Vercel             | Slidev | [`2025/slidev-mobile-claude`](2025/slidev-mobile-claude/)         |
| 2026-02-13              | TerraformでNixOSをデプロイする                  | Marp   | [`2026/nix-lt`](2026/nix-lt/)                                     |
| 2026-03                 | 単眼カメラを用いたVR向け仮想トラッカーの制作    | Typst  | [`2026/post-2603`](2026/post-2603/)                               |
| 2026-03-11              | 私がNixについてやったこと                       | Slidev | [`2026/nix-journey`](2026/nix-journey/)                           |
| 2026-05-27              | TEEを活用したNix Binary Cacheの信頼スコアリング | Typst  | [`2026/nix-cache-05-27`](2026/nix-cache-05-27/)                   |
| 2026-05-30              | 会話の温度計                                    | Slidev | [`2026/conversation-thermometer`](2026/conversation-thermometer/) |
| 2026-06-05              | Nix Binary CacheとTEE                           | Slidev | [`2026/nix-tee`](2026/nix-tee/)                                   |
| 2026-06-06              | NixOSでMinecraftサーバーを構築する              | Slidev | [`2026/nix-minecraft`](2026/nix-minecraft/)                       |
| 2026 summer — 1st event | SecHack365 テーマ概要（Slidev）                 | Slidev | [`2026/sechack-1st-event`](2026/sechack-1st-event/)               |
| 2026 summer — 2nd event | SecHack365 テーマ概要（Typst flyer）            | Typst  | [`2026/sechack-2nd-event`](2026/sechack-2nd-event/)               |

## Development

Nix を使う場合は、リポジトリルートで開発環境に入ります。

```bash
nix develop
just list
```

Slidev の起動とビルド:

```bash
just dev nix-journey
just build-slides nix-journey
```

Marp のプレビューとPDF出力:

```bash
cd 2026/nix-lt
bun install
cd ../..
just dev-marp
just build-marp
```

Typst ポスターのビルド:

```bash
just build-poster post-2603
just build-poster nix-cache-05-27
just build-slides sechack-1st-event
just build-poster sechack-2nd-event
```

`nix flake check` または `just check` は、3つの Typst ポスターをすべてビルドします。

リポジトリ全体の整形には treefmt を使います。

```bash
nix fmt
```

Alejandra（Nix）、Prettier（Markdown / JSON / YAML / TypeScript / Vue）、typstyle（Typst）、shfmt（Shell）、`terraform fmt`、gofmt がまとめて実行されます。`nix develop` に入ると git-hooks.nix が同じtreefmtチェックをpre-commit hookとして設定します。`nix flake check` でも整形状態とhookを検証します。

全資料のPDFとPages用のMarkdown索引をまとめて生成する場合:

```bash
just build-all-pdfs
```

成果物は `_site/` に生成されます。11発表から、Slidev 7件、Marp 1件、Typst 3件の計11 PDFを作成します。

## GitHub Pages

`.github/workflows/deploy-pages.yml` は `main` へのpushまたは手動実行で、次を自動実行します。

1. Nix開発環境を用意する
2. treefmt、git-hooks.nix、Typstビルドを `nix flake check` で検証する
3. Slidev、Marp、Typstの全資料をPDF化する
4. 全PDFへの箇条書きリンクを持つ `_site/index.md` を生成する
5. GitHub公式のJekyll ActionとPrimerテーマでMarkdownをビルドする
6. 生成サイトをGitHub Pagesへデプロイする

PDFはGitへコミットせず、毎回ソースからActions上で生成します。初回のみリポジトリの **Settings → Pages → Build and deployment → Source** を **GitHub Actions** に設定してください。

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
├── flake.nix
└── justfile
```

各 Slidev プロジェクトは、移行時点の `bun.lock` と個別の `package.json` を保持しています。依存関係は各Slidevプロジェクトのディレクトリで `bun install --frozen-lockfile` を実行してください。

## Migration notes

次の3リポジトリの現行ワークツリー（未コミット変更を含む）から移行しました。

- `/home/akazdayo/programs/LT-slides`
- `/home/akazdayo/programs/sechack/slides`
- `/home/akazdayo/programs/post-2603`

資料本体、画像、ロックファイル、発表用デモは保持しています。`.git`、`.direnv`、`node_modules`、Slidevの `dist`、Typstの生成PDFなど、履歴またはソースから再生成できるものは移行対象外です。
