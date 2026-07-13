---
theme: apple-basic
drawings:
  persist: false
mdc: true
layout: intro
transition: null
---

# 説明

---

# 自己紹介

<div class="flex justify-center mt-0 pt-0">
  <div class="pt-6 pb-24 px-24 text-center flex flex-col items-center">
    <img src="https://avatars.githubusercontent.com/u/82073147?v=4" class="rounded-full w-48 h-48 border-1 border-gray-200 shadow-md mx-auto" />
    <h2 class="text-gray-500 font-bold mt-4">@akazdayo</h2>
    <h1 class="mt-2">あかず</h1>
  </div>
  <div class="pt-6 pb-24 px-24 text-left overflow-hidden">
    <h2>趣味</h2>
    <div class="text-left">
      <ul>
        <li>
          技術
          <ul>
            <li>Nix</li>
            <li>分散SNS</li>
            <li>インフラ(最近始めた)</li>
          </ul>
        </li>
        <li>ゲーム
          <ul>
            <li>osu!</li>
            <li>VRChat</li>
            <li>etc...</li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</div>

---

# 1. 背景

- Nixにはつらいところが多すぎる
  - すべてをサンドボックスでビルドするためオーバーヘッドが大きい
  - キャッシュの再利用性が低い
  - ディスク容量を大きく消費する

---

# それを解決するには

- バイナリキャッシュという仕組みがある
  - Nixは入力から同一の出力をほぼ保証している

- 手順
  - 1.入力データをキャッシュサーバーに問い合わせ、署名済みバイナリキャッシュを求める
  - 2.バイナリキャッシュの署名を検証、ユーザーが信頼するものであれば承認
  - 3.インストール

- **出力のハッシュ値はビルドしないとわからない**

---

# バイナリキャッシュの課題

- キャッシュ利用者は署名鍵への盲目的な信頼が必要となる
  - 信頼した鍵が不正なキャッシュを投稿しても見抜けない (出力のハッシュ値はビルドしないとわからないため)
    - 利用者が多い特定の大規模リポジトリにユーザーが集中する
- 小規模リポジトリは、ユーザー数が少ないため信頼のための検討材料が少ない
  - キャッシュを持ちにくいため、大規模リポジトリに対する依存が深まる

---

# 2. 目的

- 現状は、信頼する/しないの二値であるため、
- **cache運営者を盲信せず、成果物ごとの信頼性を判断できる指標を作りたい**

---

# 3. ざっくり仮説

- 実際にビルドしたことを検証可能なデータを作成
- そのデータを分散台帳上にアップロード
- 利用者は信頼するか否かの指標を得られる

---

# 実際にビルドしたことを検証するには

以下が使えそう

- TEE
- ゼロ知識証明
- ログ公開

だけど、ゼロ知識証明は難しそう

- LinuxをまるっとSandboxして動かす感じになるので処理が重そう
- zkVMはRISC-V向けが主流である

---

# 4. 不安点

- TEEだけではSybil攻撃に対する完全な耐性になれなさそう
  - CPUプロバイダを完全信頼することになる
  - TEEの脆弱性が無いとは言えない
  - TEEを借りることは容易である
    - Azure Confidential Computing
    - Google Cloud Confidential VM
    - など

---

# 5. 相談したいこと

- TEEをどこまで信頼するか
- Sybilをどうやって完全に防ぐか
- 見るべき先行研究
