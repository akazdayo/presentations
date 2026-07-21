# presentations

過去のプレゼンテーション資料をまとめたリポジトリです！Actionsで自動デプロイしてるー
https://akazdayo.github.io/presentations

## Development

Nix を使う場合は、リポジトリルートで開発環境に入ります。

```bash
nix develop
just list
```

形式にかかわらず、カタログ名を指定して起動・ビルドできます。
Typst の `dev` は Typix の watch を起動し、保存するたびに
`poster/poster.pdf` を更新します。自動リロード対応の PDF ビューアーで開いてください。

```bash
just dev nix-journey
just dev nix-lt
just dev post-2603
just build nix-journey
just build nix-lt
just build post-2603
```

`scripts/lib/presentations.ts` は年別ディレクトリを走査して資料を自動検出し、
共通バックエンドインターフェイスが Slidev、Marp、Typst の形式固有処理を
吸収します。`just` の各コマンドと Pages のサイト生成は同じ検出結果を参照します。

各発表の `presentation.json` には、一覧やPagesで表示する日付とタイトルだけを
記述します。ファイルまたは項目がない場合は `TBD` と `Untitled (<name>)` が使われます。

```json
{
  "date": "2026-03-11",
  "title": "私がNixについてやったこと"
}
```

`nix flake check` または `just check` は、3つの Typst ポスターをすべてビルドします。

リポジトリ全体の整形には treefmt を使います。

```bash
nix fmt
```

Alejandra（Nix）、Prettier（Markdown / JSON / YAML / TypeScript / Vue）、typstyle（Typst）、shfmt（Shell）、`terraform fmt`、gofmt がまとめて実行されます。`nix develop` に入ると git-hooks.nix が同じtreefmtチェックをpre-commit hookとして設定します。`nix flake check` でも整形状態とhookを検証します。

全資料のWeb成果物とPages用のMarkdown索引をまとめて生成する場合:

```bash
just build-site
```

成果物は `_site/` に生成されます。Slidev 7件とMarp 1件は静的Webページ、Typst 3件はPDFとして出力されます。
同時に `/.well-known/presentations.json` へ、各資料の公開URL・タイトル・日程を配列として生成します。
公開URLのベースを変更する場合は `PAGES_BASE_URL` 環境変数を指定してください。

## GitHub Pages

`.github/workflows/deploy-pages.yml` は `main` へのpushまたは手動実行で、次を自動実行します。

1. Nix開発環境を用意する
2. GitHub Pagesのサブパスを取得する
3. Slidev、Marp、Typstの全資料をWeb表示用にビルドする
4. 資料への箇条書きリンクを持つ `_site/index.md` を生成する
5. GitHub公式のJekyll ActionとPrimerテーマでMarkdownをビルドする
6. 生成サイトをGitHub Pagesへデプロイする

生成物はGitへコミットせず、毎回ソースからActions上で生成します。初回のみリポジトリの **Settings → Pages → Build and deployment → Source** を **GitHub Actions** に設定してください。

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
