---
theme: apple-basic
drawings:
  persist: false
mdc: true
layout: intro
transition: null
---

# Nostrを一年間使ってみた感想

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
        <li>Nostr</li>
        <li>
          プログラミング
          <ul>
            <li>Typescript</li>
            <li>Nix</li>
            <li>Python(嫌い)</li>
            <li>Gleam(興味あるだけ)</li>
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
layout: center
---

# みなさん、分散型SNSって知ってますか？

---
layout: center
---

## まさか中央集権型SNSなんて使ってないですよね...？

---
layout: fact
---

<h2 class="text-center">
  今更言われても...
  <br>
  よくわからない...
  <br>
  そもそもSNSってなに？
  <br>
  そもそも分散型ってなに？
</h2>

---

## 中央集権と非中央集権の例

- 中央集権型SNS
  - Facebook <img src="https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg" alt="Facebook" width="24" style="vertical-align: middle;"/>
  - Twitter <img src="https://upload.wikimedia.org/wikipedia/commons/6/6f/Logo_of_Twitter.svg" alt="Twitter" width="24" style="vertical-align: middle;"/>
  - Instagram <img src="https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png" alt="Instagram" width="24" style="vertical-align: middle;"/>
- 非中央集権型SNS
  - Mastodon
  - Misskey
  - Bluesky
  - Nostr
  - etc...

---
layout: center
---

<img src="https://storage.googleapis.com/zenn-user-upload/ab2f980a2124-20231210.png"/>
<p style="font-size: 0.8em; text-align: right;">
  引用元：<a href="https://zenn.dev/mattn/articles/cf43423178d65c" target="_blank" rel="noopener" class="text-blue-500">https://zenn.dev/mattn/articles/cf43423178d65c</a>
</p>

---
layout: two-cols
---

## 主な違い

- 権利者が誰か
- データの管理
- 単一障害点の有無

::right::

## ユーザーから見て嬉しいところ(Nostrの場合)

- 鯖落ちという概念が存在しない
- データの管理がユーザーに委ねられている
- わけわからん「おすすめ」TLを強制されない
  - おすすめなんてどうでも良いから、見たいデータを自分で決めさせて欲しい。
- **こんな機能がほしい？自分で作ればいいじゃん**

<!--
- 権利者が誰か(中央集権型SNSはFacebook, Twitter, Instagramなどの企業が管理しているが、非中央集権型SNSはユーザーが管理している)
- データの管理(中央集権型SNSは企業が管理しているが、非中央集権型SNSはユーザーが管理している)

イーロン・マスクの一存で、全てのデータを削除できるか、できないか。とかの考え方が良さそう？
-->

---

## 結局どれくらいNostrを使ったの？

<img src="https://share.yabu.me/1beecee55f69ebc2890403606f28b5e8ebbab23d226730e12b4bf762d29d2162/2cd343d471fed4e9617d4dc44b8142da9ef03f6e1129025f6bb684767aa0d524.webp" class="rounded-xl"/>

- 3月くらいから使い始めた！
- 10月からは毎日使ってたみたい。

<!--
かなりNostrに入り浸った日々を過ごしたと思う

ちなみに、これはGeminiのCanvasモードで作りました！
-->

---


---

## 私がこれだけNostrに入り浸った理由

- エンジニアが多い
- ビットコインオタクが沢山いる
- **現状のNostrのエコシステムはほぼ全てOSSであり、自由に利用できる**
- **空リプの文化**
- **データの利用が自由(API Limitが存在しない場合が多い)**

---


---

## Nostr特有の空リプの良さ

もし、面白そうな話をしている人がいたとして、Twitterだったら途中で会話混ざってきて「何だこいつ」になってしまうケースがある。

Nostrだったら、通常のTLでみんなが会話をしているので、誰でも自由に会話に参加できる。

---
layout: two-cols
---

## 誰でも自由にBOTが作れる

- フォローTLを取得して、自動的に要約をしてくれるボットが作れる
- もしTwitterだったらAPIでタイムライン取得できないから実装不可

::right::

<img src="https://share.yabu.me/1beecee55f69ebc2890403606f28b5e8ebbab23d226730e12b4bf762d29d2162/0b19bf1b12d38090f7aefd751052d1dd04aa1185f3c8cc349ac97d495ade4abc.webp" class="rounded-xl"/>

---
layout: center
---

<div class="flex justify-center items-center">
<h2>誰でも自由にクライアントが作れる</h2>
<br/>
<img src="data:image/gif;base64,R0lGODlhdAB0AJEAAAAAAP///wAAAAAAACH5BAEAAAIALAAAAAB0AHQAAAL/jI+py+0Po5y02ouz3rz7D4biSJbmiabqyrZuCcTyTNc2YucAM+OyrwveJsIiDWjk/Q49pvFJeUKdU0XTcA1Ik8StEFlUxpBgby26tGRz5TF19yZfshB6140d5s/x/h6ulhZhJ7Gmp3VoiIe4iNb4QDgoyPamCMh4GVknuLkY5ifpyQlqSfnnmPkF2pn6eEqq+lo4GYuJKmdFKxqEG9qq08saDLsLvAqpayxri1yVUJo46gDNt6xZWdv7uSyMXc3MvbAl9msK7tt2RHxJvv2cbH6dWxwv3WCerl0r/04f7XrvUL519QCSS2cJVaSC5f6xa9bwG7+B89RZ22fv4Bx7/wwXJsMw8dgsgB05ftxoUFxGiO3gmSwGcmXFmCQdeoSJ8uE0M8rOJVyHkKdCnj8v4jRK1KKvpCeR6vPHdGhUoFSRMk2p4qZSdy9gvNyaresIrdSUih37tWxIE2WD1nwb8ZfGP2t92hQo0q7ErxTReYurdS6mov3i3vrrVue5p2Dh9mVFWG1amQGxLr7TWO5fspQFe8Yc2eW3x5i7Bdp7dDBeup1VWq4reBziza3DZRXds+Roli8ko86Mj7cL38Bx14W9wR1nxxCVhz2dezLznc645mTYcnplLqx3Q8fu2mzexMQ56I6emjj47uKpF+dVVa8XxsHdq28qn7zDxFIB7/+PTxR9q1Ug20y0QfVee4WZJ0VsGMHHHj/IVWSdVXf9Vt+CyTUYHn8H+vdabYU5Vx1+NBm2YYkqaqZBWylypxqE+b1I2ncPwkjYiTX6xR5kHFJ4o4QiumjfjyMGSdlxuPnojH4ImsZjjIo5qWCBUkJ5IpGXGWjhVQP215eQ6Xn5HIEXsridgGQqCOZstmnY5ZoiklAhnFvamWNvZTIGZZ7D7Rmfg6l1VSefws04Epk7holfeaBdtaibiMqXYXZJRdojgMYNKSemV2qKoJKWCarYfSGeOmWHOQ0TZ6XjvcqlmYMSBOibrKa5al6mpmorrHjeiKWkXoLgaK9vnmclg6GpmqgqkMs2SeOHt96KrJHKgoimn7hmGmGtv8oY2qi0PttTn8AGemi1MpoLbqOcPvmhq7GSiGab8y6Za7djiutsqe56FyW90zbH17i8bitluAdbSqqnnyVqaYC6MgudjuENO/GsFed75FTHUizrws12fGnG9V4HqbBzXpxyohhze2d/Ervc8qfGLlUzkyXDPCHJM58FdNBCD0100UYfjXTSSi/NdNNOPz1BAQA7">
</div>

---


---

## 実際に投稿を組み立ててみよう

```ts {monaco-run}
import {
  generateSecretKey,
  getPublicKey,
  finalizeEvent,
} from "nostr-tools/pure";

// 鍵を生成
const sk = generateSecretKey();
const pk = getPublicKey(sk);

// 投稿を作成＆署名
const event = finalizeEvent(
  {
    kind: 1,
    created_at: Math.floor(Date.now() / 1000),
    tags: [],
    content: "こんにちは、Nostr！",
  },
  sk,
);

console.log(event);
```

---
layout: center
---

<img src="https://storage.googleapis.com/zenn-user-upload/ab2f980a2124-20231210.png"/>
<p style="font-size: 0.8em; text-align: right;">
  引用元：<a href="https://zenn.dev/mattn/articles/cf43423178d65c" target="_blank" rel="noopener" class="text-blue-500">https://zenn.dev/mattn/articles/cf43423178d65c</a>
</p>

---
layout: center
---

ご清聴ありがとうございました！
<img src="data:image/gif;base64,R0lGODlhdAB0AJEAAAAAAP///wAAAAAAACH5BAEAAAIALAAAAAB0AHQAAAL/jI+py+0Po5y02ouz3rz7D4biSJbmiabqyrZuCcTyTNc2YucAM+OyrwveJsIiDWjk/Q49pvFJeUKdU0XTcA1Ik8StEFlUxpBgby26tGRz5TF19yZfshB6140d5s/x/h6ulhZhJ7Gmp3VoiIe4iNb4QDgoyPamCMh4GVknuLkY5ifpyQlqSfnnmPkF2pn6eEqq+lo4GYuJKmdFKxqEG9qq08saDLsLvAqpayxri1yVUJo46gDNt6xZWdv7uSyMXc3MvbAl9msK7tt2RHxJvv2cbH6dWxwv3WCerl0r/04f7XrvUL519QCSS2cJVaSC5f6xa9bwG7+B89RZ22fv4Bx7/wwXJsMw8dgsgB05ftxoUFxGiO3gmSwGcmXFmCQdeoSJ8uE0M8rOJVyHkKdCnj8v4jRK1KKvpCeR6vPHdGhUoFSRMk2p4qZSdy9gvNyaresIrdSUih37tWxIE2WD1nwb8ZfGP2t92hQo0q7ErxTReYurdS6mov3i3vrrVue5p2Dh9mVFWG1amQGxLr7TWO5fspQFe8Yc2eW3x5i7Bdp7dDBeup1VWq4reBziza3DZRXds+Roli8ko86Mj7cL38Bx14W9wR1nxxCVhz2dezLznc645mTYcnplLqx3Q8fu2mzexMQ56I6emjj47uKpF+dVVa8XxsHdq28qn7zDxFIB7/+PTxR9q1Ug20y0QfVee4WZJ0VsGMHHHj/IVWSdVXf9Vt+CyTUYHn8H+vdabYU5Vx1+NBm2YYkqaqZBWylypxqE+b1I2ncPwkjYiTX6xR5kHFJ4o4QiumjfjyMGSdlxuPnojH4ImsZjjIo5qWCBUkJ5IpGXGWjhVQP215eQ6Xn5HIEXsridgGQqCOZstmnY5ZoiklAhnFvamWNvZTIGZZ7D7Rmfg6l1VSefws04Epk7holfeaBdtaibiMqXYXZJRdojgMYNKSemV2qKoJKWCarYfSGeOmWHOQ0TZ6XjvcqlmYMSBOibrKa5al6mpmorrHjeiKWkXoLgaK9vnmclg6GpmqgqkMs2SeOHt96KrJHKgoimn7hmGmGtv8oY2qi0PttTn8AGemi1MpoLbqOcPvmhq7GSiGab8y6Za7djiutsqe56FyW90zbH17i8bitluAdbSqqnnyVqaYC6MgudjuENO/GsFed75FTHUizrws12fGnG9V4HqbBzXpxyohhze2d/Ervc8qfGLlUzkyXDPCHJM58FdNBCD0100UYfjXTSSi/NdNNOPz1BAQA7">
