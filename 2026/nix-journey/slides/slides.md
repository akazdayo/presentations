---
theme: default
title: 私がNixについてやったこと
info: |
  Nostrの投稿をもとに振り返る、Nix/NixOSとの格闘と定着。
class: text-slate-700 bg-white
drawings:
  persist: false
transition: slide-left
comark: true
duration: 10min
timer: countdown
colorSchema: light
---

---
layout: cover
---

# 私がNixについてやったこと

<div class="mt-6 text-2xl text-slate-900 font-500">
  「神すぎる」と「寝たい本当に」のあいだ
</div>

<div class="mt-12 grid grid-cols-3 gap-4 text-left">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3">
    <div class="text-xs uppercase tracking-widest text-slate-500">start</div>
    <div class="mt-2 text-lg">Nixってなんかかっこいいよね</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3">
    <div class="text-xs uppercase tracking-widest text-slate-500">middle</div>
    <div class="mt-2 text-lg">nix flakeに感動しすぎて寝れない</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3">
    <div class="text-xs uppercase tracking-widest text-slate-500">now</div>
    <div class="mt-2 text-lg">最近普通にNix妖怪なんだよなー</div>
  </div>
</div>

<div class="absolute bottom-8 left-12 text-sm text-slate-500">
  Nostrの投稿をそのまま素材にした、かなり個人的なNix遍歴です
</div>

<!--
0:30
最初に感情の幅を見せて、この発表が教科書ではなく実録だと伝える。
今日は 1) なぜ触ったか 2) 何をやったか 3) 今どう思っているか、の順で話す。
-->

---
layout: two-cols
---

# なぜ Nix に触ったのか

<v-clicks>

- Windowsや環境をわりと壊しがちだった
- 再インストールのたびに一から戻すのがつらかった
- プロジェクト依存関係も、サーバー構築も、毎回やり直したくなかった
- だから最初の動機は「思想」より先に <span class="font-bold text-slate-900">再現性への救済</span> だった

</v-clicks>

::right::

<div class="space-y-4 pt-10">
  <div class="rounded-2xl border border-gray-200 bg-white px-4 py-4 text-sm leading-relaxed shadow-sm">
    「よく環境破壊してる自分にとっては神すぎるOSですわね」
  </div>
  <div class="rounded-2xl border border-gray-200 bg-white px-4 py-4 text-sm leading-relaxed shadow-sm">
    「何回も再インストールしてるから nix で再現性確保したいのがモチベ」
  </div>
  <div class="rounded-2xl border border-gray-200 bg-white px-4 py-4 text-sm leading-relaxed shadow-sm">
    「マイクラのサーバーとか定期的に立てるけど、毎回一から環境構築してた」
  </div>
</div>

<!--
0:45
最初の入口は理念よりも、壊れる現実に対する切実さだったことを強調する。
Windows やサーバー構築のやり直しコストが高く、再現性そのものが欲しかった話をする。
-->

---
layout: two-cols
---

# 最初の印象はかなり単純だった

<div class="space-y-4 pt-4">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">first thought</div>
    <div class="mt-2 text-2xl">Nixってなんかかっこいいよね</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">first win</div>
    <div class="mt-2 text-lg">プロジェクトの依存関係管理が本当に楽</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">honeymoon</div>
    <div class="mt-2 text-lg">nix flakeに感動しすぎて寝れない</div>
  </div>
</div>

::right::

## この時点で刺さっていたもの

<v-clicks>

- `flake.nix` で入口が見えた
- `nix develop` を毎回打つだけでも気持ちよかった
- `mise` や `asdf` より守備範囲が広く見えた
- まだ理解は浅いけど、便利さはもう感じていた

</v-clicks>

<div class="mt-6 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-500">
  「Nixは全部管理できちゃうから好き好き大好き」
</div>

<!--
0:45
最初は理解より先に手触りで好きになっていた。
flake や devShell の入口だけでもかなり未来感があったことを話す。
-->

---
layout: center
---

# でも、すぐにこうなった

<div class="mt-10 grid grid-cols-2 gap-5 text-left">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-5 py-5">
    <div class="text-sm uppercase tracking-widest text-slate-500">confusion</div>
    <div class="mt-3 text-2xl leading-snug">Nix大変すぎる。<br>寝たい本当に</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-5 py-5">
    <div class="text-sm uppercase tracking-widest text-slate-500">question</div>
    <div class="mt-3 text-2xl leading-snug">flakeってなんで<br>試験的機能なんだろう</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-5 py-5">
    <div class="text-sm uppercase tracking-widest text-slate-500">help</div>
    <div class="mt-3 text-xl leading-snug">Nix有識者の知り合いが欲しい</div>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-5">
    <div class="text-sm uppercase tracking-widest text-slate-500">reality</div>
    <div class="mt-3 text-xl leading-snug">雰囲気で書けても、<br>ちゃんと理解しないと前に進めない</div>
  </div>
</div>

<div class="mt-8 text-lg text-slate-500">
  このあたりで、<span class="font-bold text-slate-900">「かっこいい技術」から「ちゃんと向き合う技術」</span> に変わった
</div>

<!--
0:40
テンションが高い時期の直後に、ちゃんと意味がわからず詰まった話を入れる。
この slide は感情の転換点として使う。
-->

---
layout: two-cols
---

# いちばん大きかった認識の変化

## 最初の理解

- ツールチェイン管理のすごい版っぽい
- 依存関係をまとめるものっぽい
- `devShell` が便利、くらいの感覚

::right::

## 後から腑に落ちたこと

<v-clicks>

- 「サンドボックスでビルドする理由も完全に理解した」
- 「Nixはビルドシステムですよ」
- 「miseはツールチェイン管理、nixはビルドツール」
- 「Dockerは環境づくり、Nixはビルド再現性」

</v-clicks>

<div class="mt-6 rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm leading-relaxed">
  個人的にはここでやっと、Nixの便利さではなく <span class="font-bold text-slate-900">Nixが何を守ろうとしているか</span> が見えた
</div>

<!--
0:50
この slide が発表の芯。
Nix を単なる version manager の延長として見ていた時と、build/reproducibility の技術として見えた後で、理解が変わったと説明する。
-->

---
layout: section
---

# ここから、触るだけじゃなくなった

<div class="mt-8 grid grid-cols-3 gap-4 text-left">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">1</div>
    <div class="mt-2 text-lg">開発環境</div>
    <div class="mt-2 text-sm text-slate-500">flake / devShell / project env</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">2</div>
    <div class="mt-2 text-lg">OS と dotfiles</div>
    <div class="mt-2 text-sm text-slate-500">NixOS / WSL / Home Manager / NixVim</div>
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">3</div>
    <div class="mt-2 text-lg">パッケージ・運用</div>
    <div class="mt-2 text-sm text-slate-500">server / nixpkgs / packaging / 実運用の痛み</div>
  </div>
</div>

<!--
0:15
ここから後半戦。実際に何を触ったのかを 3 章に分けて話すと伝える。
この slide 自体は短く、道案内として使う。
-->

---
layout: two-cols
---

# まずは開発環境から

<v-clicks>

- プロジェクトの依存関係管理に Nix を使い始めた
- `flake.nix` / `devShell` にかなり感動した
- 「単純に pnpm 入れて build するだけでは Nix の意味が薄い」と気づいた
- その流れで `pnpm2nix` や `dream2nix` も追いかけ始めた

</v-clicks>

::right::

```bash
nix develop
nix flake init -t templates#python
nix flake update
```

<div class="mt-5 rounded-2xl border border-gray-200 bg-white px-4 py-3 text-sm leading-relaxed shadow-sm">
  「毎回新しいターミナル開くたびに nix develop 打ってたから超感動した」
</div>

<div class="mt-4 rounded-2xl border border-gray-200 bg-white px-4 py-3 text-sm leading-relaxed shadow-sm">
  「できることとできないことを把握したい」と思うくらいには、もう日常の道具になっていた
</div>

<!--
0:50
まずは一番現実的な入口として、project env 管理の話をする。
Nix をいきなり OS に入れるより、開発環境で使うのがわかりやすかったこともここで触れる。
-->

---
layout: two-cols
---

# NixOS / WSL まで踏み込んだ

<v-clicks>

- WSL 上の NixOS を試した
- その後、ちゃんと NixOS を入れて設定も進めた
- 壊れても戻しやすいことにかなり救われた
- NVidia driver みたいな重そうなものも、思ったより簡単だった

</v-clicks>

::right::

<div class="space-y-4 pt-6">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4 text-sm leading-relaxed">
    「WSLのNixOS簡単だよ」
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4 text-sm leading-relaxed">
    「NixOS設定できた！」
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4 text-sm leading-relaxed">
    「データ消えてもすぐに復旧できるから全人類使った方がいい」
  </div>
  <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-xs text-slate-500">
    `nixos-rebuild switch --flake .#machine`
  </div>
</div>

<!--
0:50
WSL から入り、その後ちゃんと NixOS に進んだ流れを話す。
壊れても戻せる安心感が、単なる便利さより大きかったと説明する。
-->

---
layout: two-cols
---

# dotfiles もエディタも外に出てきた

## やったこと

<v-clicks>

- `home.nix` を flake 化
- Home Manager の便利さについて記事を書いた
- 友達に NixOS セットアップを教えた
- `NixVim` / `nixvim` 周りも触って Neovim を組み始めた

</v-clicks>

::right::

<div class="space-y-4 pt-4">
  <div class="rounded-2xl border border-gray-200 bg-white px-4 py-4 text-sm leading-relaxed shadow-sm">
    「日本語文献が少なすぎることに気づいたので、HomeManagerの便利さについて語る記事を書いた」
  </div>
  <div class="rounded-2xl border border-gray-200 bg-white px-4 py-4 text-sm leading-relaxed shadow-sm">
    「自分がNixOSを教えた友達が記事を書いてくれた！」
  </div>
  <div class="rounded-2xl border border-gray-200 bg-white px-4 py-4 text-sm leading-relaxed shadow-sm">
    「NixVim使ってnvim入れた！結構いいかんじ」
  </div>
</div>

<!--
0:45
ここでは、Nix が自分の環境だけでなく他人に共有できるものになっていった話をする。
記事を書いたり友達に教えたりしたことで、理解が固まったことも補足する。
-->

---
layout: two-cols
---

# さらにパッケージ・サーバー・インフラへ

<div class="grid grid-cols-2 gap-4 pt-4 text-sm">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    アプリや package の Nix を書き始めた
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    Minecraft サーバーを毎回使える形にしたかった
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    カーソルみたいな細かいものまで Nix で管理した
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    Terraform + Nix や nixpkgs 側も気になり始めた
  </div>
</div>

::right::

<v-clicks>

- Minecraft サーバーを毎回使える環境にしたいと考えた
- Proxmox や relay みたいなサーバー寄りの用途も追いかけた
- `nixpkgs` の PR や package 定義を見る側にも回り始めた
- つまり Nix は「使うもの」から「書くもの」に変わっていった

</v-clicks>

<!--
0:35
この slide は breadth を見せるために使う。
全部を詳しく話すのではなく、代表例を 2 つだけ話して、気づいたら対象がどんどん広がっていたという勢いを伝える。
-->

---
layout: center
---

# ただし、普通につらい

<div class="mt-8 grid grid-cols-3 gap-4 text-left text-sm">
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">build</div>
    一部パッケージがセルフビルドで重い
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">docs</div>
    文献が少なく、雰囲気実装になりやすい
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">disk</div>
    flake update や世代管理で容量がつらい
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">ecosystem</div>
    `unstable` を広く使うと壊れやすい
  </div>
  <div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">linux</div>
    FHS 非準拠で、普通にビルドするとパスが足りなくて死ぬ
  </div>
  <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4">
    <div class="text-xs uppercase tracking-widest text-slate-500">ops</div>
    config を public にした時の運用の辛さもある
  </div>
</div>

<div class="mt-8 text-xl text-slate-900">
  「NixOS辛いなー」も「Nixの嫌いなところ出てきたわー」も、かなり本音
</div>

<!--
0:40
ここは honest downside の slide。
好きだけど辛い、という両方を言うことで発表全体の信頼感を上げる。
容量、self-build、FHS の 3 つを中心に話せば十分。
-->

---
layout: two-cols
---

# それでも今はこう思っている

## 好きな理由

<v-clicks>

- 壊れやすい環境を、もう一度作れる形で持てる
- OS から dotfiles まで一続きで扱える
- 理解が進むほど楽しくなる
- 友達に教えたり、記事にしたりしたくなる

</v-clicks>

::right::

## 現在の立場

<div class="rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4 text-sm leading-relaxed">
  「Nixって今後絶対くる技術だと思う」
</div>

<div class="mt-4 rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4 text-sm leading-relaxed">
  「個人的には Nix はまだ発展途上すぎると思う」
</div>

<div class="mt-4 rounded-2xl border border-gray-200 bg-gray-50 px-4 py-4 text-sm leading-relaxed">
  おすすめ順としては、<span class="font-bold text-slate-900">まず project env → その後に NixOS</span> くらいがちょうど良さそう
</div>

<!--
0:45
最終的な温度感をまとめる slide。
「めちゃくちゃ好きだけど、誰にでもいきなり全部は勧めない」という立場を言語化する。
-->

---
layout: center
---

# 結論

<div class="mt-10 mx-auto max-w-4xl rounded-3xl border border-gray-200 bg-gray-50 px-8 py-8 text-left">
  <div class="text-2xl leading-relaxed">
    Nix は最初から快適な技術じゃないです。<br>
    でも、<span class="font-bold text-slate-900">壊れやすい現実を再現可能にしてくれる</span> ところが本当に強い。
  </div>
  <div class="mt-6 text-lg text-slate-500">
    だから自分は、苦しみつつもかなり好きです。
  </div>
</div>

<div class="mt-10 text-3xl text-slate-900 font-600">
  最近普通に Nix 妖怪なんだよなー
</div>

<div class="mt-4 text-slate-400">
  ありがとうございました
</div>

<!--
0:30
最後は「便利だった」ではなく、なぜ手放せなくなったのかで締める。
クリック待ち込みで 10 分に収めるため、実際には 9 分台前半で着地するつもりで話す。
-->
