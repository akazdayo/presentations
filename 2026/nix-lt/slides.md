---
marp: true
theme: gaia
---

# 完全に再現可能なインフラを構築してみよう

---

## 従来のインフラ構築手順

1. ベンダーのWebサイトにアクセス
2. 新しいコンテナ/VMを立てる
3. SSHでごちゃごちゃ
4. なんか動いたっ！

## 問題点

- 変更点をチームで共有しにくい
- Gitでバージョン管理ができない
- **ミスをしたときに本番環境がストップする可能性がある**

---

## じゃあどうする？

1. TerraformでベンダーのWeb操作を自動化
2. NixOSを使ってOSの操作に再現性を持たせる

![Image](https://brand.nixos.org/logos/nixos-logo-default-gradient-black-regular-horizontal-recommended.svg)

---

## これをやる素敵さ

- GUIとか言う諸悪の根源を触る必要がない
  - Webサイトは人間用のインターフェイスなのでわかりにくい
- shellを触る必要がない
- **ビルドエラーが発生する**
  - インフラをビルドできるので、悪い操作をしたときに自動的にビルドエラーが発生する

---

## 簡単に試してみよう

---

## コマンドの比較：SSH/Git vs Nix

---

<div class="columns">
<div>

### 通常のSSH/Git管理

```bash
# サーバーにSSH接続
ssh user@server

# パッケージインストール
sudo apt-get update
sudo apt-get install nginx

# 設定ファイル編集
sudo vim /etc/nginx/nginx.conf

# サービス再起動
sudo systemctl restart nginx

# 手動でGit管理
git add .
git commit -m "Update nginx config"
```

</div>
<div>

### Nix管理

```nix
# configuration.nix
{
  services.nginx = {
    enable = true;
    # 設定はコードとして記述
  };
}
```

```bash
# ビルド＆デプロイ
nixos-rebuild switch

# 自動的にGitで管理可能
# 設定ミスはビルド時に検出
```

</div>
</div>

---

## なぜNixが優れているか

<div class="columns">
<div>

### 従来の方法の問題

- 手動操作でミスが起きやすい
- 環境依存の問題
- 再現が困難
- ロールバックが面倒

</div>
<div>

### Nixの利点

- **宣言的**：コードで管理
- **再現可能**：どこでも同じ環境
- **安全**：ビルドエラーで事前検出
- **簡単なロールバック**

</div>
</div>

---

![bg opacity](https://picsum.photos/800/600?image=53)

## 7. Columns

<div class="columns">
<div>

## Left

- 1
- 2

</div>
<div>

## Right

- 3
- 4

</div>
</div>

---

## 8. Icons

<i class="fa-brands fa-twitter"></i> Twitter:
<i class="fa-brands fa-mastodon"></i> Mastodon:
<i class="fa-brands fa-linkedin"></i> LinkedIn:
<i class="fa fa-window-maximize"></i> Blog:
<i class="fa-brands fa-github"></i> GitHub:

---

# 9. <!--fit--> Large Text

---

<!-- Needed for mermaid, can be anywhere in file except frontmatter -->
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
  mermaid.initialize({ startOnLoad: true });
</script>

# 10. Mermaid

<div class="mermaid">
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
</div>
