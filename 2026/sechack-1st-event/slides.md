---
theme: seriph
title: Nix Binary Cache の信頼を、ビルド証拠から測る
author: 野田 蒼馬 / あかず
transition: none
highlighter: shiki
lineNumbers: false
drawings:
  persist: false
duration: 3min
---

# テーマ概要

野田 蒼馬 / あかず
SecHack365 世界観駆動コース

---
src: ../../shared/components/slidev/self-introduction.md
---

---
layout: center
---

# テーマ概要

---

# <simple-icons-nixos class="text-4xl inline-block" /> Nix とは？

宣言的なパッケージ管理・ビルドツール。

- **再現性**: 同じ設定ファイルから、誰がどこでビルドしても同一の環境を作れる
- **サンドボックスビルド**: ネットワーク遮断・専用ディレクトリでビルド → 副作用がない

<img
  src="https://static.zenn.studio/user-upload/deployed-images/bec976380f845711e5f63041.png?sha=5c1e7fc3d80fa4d57a7094d3ea801973c9439fa0"
  class="mx-auto mt-4 max-h-56 max-w-[72%] object-contain"
/>

<p class="mt-2 text-center text-xs text-gray-500">
  引用: asa1984「純粋関数的ビルド」『Nix入門』Zenn
</p>

---
layout: fact
---

## Nixってすごく面倒くさい！

---

# Why

- <span class="text-red-500">**サンドボックス上でビルドするため、ビルドがありえないほど遅い**</span>
- <span class="text-red-500">**すべてサンドボックスでビルドするのでサンドボックス内でキャッシュを使いづらい**</span>
- 細かいバージョンの指定がしにくい。(これはnixpkgsに対する不満)
- ディスク容量を非常に圧迫する
- 再現性の都合上すべてgitリポジトリに含めるのでsecretを管理しにくい
- Linux FHS非準拠なので一部ソフトウェアが動かない
- 学習曲線が急

---
layout: center
---

- **ビルドがありえないほど遅い**
- **キャッシュを使いづらい**

---
layout: center
---

# それを解決したい！

---

# 現状それを解決するもの

**Binary Cache**: ビルド済みの成果物をキャッシュして配布

- キャッシュを持つサーバー, 各パッケージのキャッシュに対する署名の２つがある
- キャッシュサーバーに問い合わせ → パッケージをもらう → 信頼する署名リストに含まれるか確認

```mermaid
flowchart LR
  client[ユーザー環境] -->|問い合わせ| cache[キャッシュサーバー]
  cache -->|パッケージ + 署名| client
  client -->|署名を照合| trusted[信頼する署名リスト]
  trusted -->|含まれる| use[パッケージを利用]
```

---

# Binary Cacheの課題

<p class="mt-1 text-lg font-semibold">
  「署名者」は確認できる。しかし、「その入力からできた成果物か」は確認できない。
</p>

<div class="mt-5 grid grid-cols-[1.55fr_0.85fr] gap-7 items-center">
  <div class="rounded-2xl border border-gray-300 bg-gray-50 px-5 py-5">
    <div class="flex items-center justify-between gap-2 text-center">
      <div class="w-28 rounded-xl border-2 border-blue-400 bg-white px-2 py-3">
        <div class="text-2xl">👤</div>
        <div class="font-bold">利用者</div>
      </div>
      <div class="flex-1">
        <div class="text-xs font-bold text-gray-500">取得</div>
        <div class="text-3xl leading-5 text-blue-500">→</div>
      </div>
      <div class="w-36 rounded-xl border-2 border-amber-400 bg-amber-50 px-2 py-3">
        <div class="font-bold">Binary Cache</div>
        <div class="mt-1 text-xs">成果物 + 署名</div>
      </div>
      <div class="flex-1">
        <div class="text-xs font-bold text-gray-500">署名を照合</div>
        <div class="text-3xl leading-5 text-blue-500">→</div>
      </div>
      <div class="w-32 rounded-xl border-2 border-emerald-400 bg-emerald-50 px-2 py-3">
        <div class="font-bold">信頼済み<br />公開鍵リスト</div>
      </div>
    </div>
    <div class="mt-4 rounded-lg bg-red-50 px-4 py-2 text-center text-sm font-bold text-red-600">
      わかるのは「誰が署名したか」まで — 入力 → 成果物の正しさは別問題
    </div>
  </div>

  <div class="space-y-3 text-sm leading-relaxed">
    <div class="rounded-xl border-l-4 border-amber-400 bg-amber-50 px-4 py-3">
      <b>信頼</b><br />署名者そのものを信じる必要がある
    </div>
    <div class="rounded-xl border-l-4 border-red-400 bg-red-50 px-4 py-3">
      <b>検証</b><br />本当にそのソースから生成されたかは不明
    </div>
    <div class="rounded-xl border-l-4 border-gray-400 bg-gray-100 px-4 py-3">
      <b>カバレッジ</b><br />未登録のパッケージは結局ローカルビルド
    </div>
  </div>
</div>

---

# 提案するアプローチ

<p class="mt-1 text-lg font-semibold">
  署名者ではなく、<b>複数の独立したビルド結果</b>を根拠に成果物を判断する。
</p>

<div class="mt-4 grid grid-cols-[1fr_1.25fr] gap-5 items-stretch">
  <div class="rounded-2xl border border-gray-300 bg-gray-50 p-4">
    <div class="mb-2 text-center text-sm font-bold text-gray-600">世界中の独立ビルダー</div>
    <div class="grid grid-cols-3 gap-2 text-center text-xs">
      <div class="rounded-lg border-2 border-violet-300 bg-white px-1 py-3"><b>Builder A</b><br />TEE / IP / Log</div>
      <div class="rounded-lg border-2 border-violet-300 bg-white px-1 py-3"><b>Builder B</b><br />TEE / IP / Log</div>
      <div class="rounded-lg border-2 border-violet-300 bg-white px-1 py-3"><b>Builder C</b><br />TEE / IP / Log</div>
    </div>
    <div class="my-1 text-center text-2xl leading-5 text-violet-500">↓</div>
    <div class="rounded-xl border-2 border-violet-400 bg-violet-50 px-3 py-3 text-center text-sm">
      <b>同じ入力をそれぞれビルド</b><br />
      入力ハッシュ → 成果物ハッシュ
    </div>
    <div class="my-1 text-center text-2xl leading-5 text-violet-500">↓</div>
    <div class="rounded-xl border-2 border-emerald-400 bg-emerald-50 px-3 py-3 text-center text-sm">
      <b>分散台帳に記録</b><br />一致度 + 独立性から信頼値を算出
    </div>
  </div>

  <div class="flex flex-col justify-center rounded-2xl border border-blue-200 bg-blue-50 p-5">
    <div class="flex items-center gap-3 text-center">
      <div class="w-28 rounded-xl border-2 border-blue-400 bg-white px-2 py-3">
        <div class="text-2xl">👤</div>
        <div class="font-bold">利用者</div>
      </div>
      <div class="flex-1">
        <div class="text-xs font-bold text-gray-500">成果物を取得</div>
        <div class="text-3xl leading-5 text-blue-500">→</div>
      </div>
      <div class="w-36 rounded-xl border-2 border-amber-400 bg-amber-50 px-2 py-3 text-sm">
        <b>Binary Cache</b><br />成果物
      </div>
      <div class="flex-1">
        <div class="text-xs font-bold text-gray-500">ハッシュを照合</div>
        <div class="text-3xl leading-5 text-blue-500">→</div>
      </div>
      <div class="w-32 rounded-xl border-2 border-emerald-400 bg-white px-2 py-3 text-sm">
        <b>台帳の<br />信頼値</b>
      </div>
    </div>
    <div class="mt-5 rounded-lg bg-white px-4 py-3 text-center text-sm font-bold text-blue-700 shadow-sm">
      台帳は成果物を配布しない。<br />利用者が「この成果物を使うか」判断するための証拠を提供する。
    </div>
    <div class="mt-3 text-center text-xs text-gray-500">
      目標は「絶対に正しい」の証明ではなく、判断できる材料を増やすこと
    </div>
  </div>
</div>

---

# 課題

- Sybil攻撃
- 実際どんなアルゴリズムでスコアリングするか
  - 現状はTEE, IPのAS番号, log情報, とか？？
  - ゼロ知識証明を使用できればアツいが、Nixのビルド全体を証明対象にするのは難しそう
- マルウェア検出ツールとの併用
  - 対象の入出力ペアが間違っている可能性があるということはマルウェアなどが混入する可能性などもある
  - VirusTotalなどを使えば良さそうだけど、私にそのあたりの知識がないのでわからない...！

---
layout: center
---

# 一年間よろしくお願いします！
