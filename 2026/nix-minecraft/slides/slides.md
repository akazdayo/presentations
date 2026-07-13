---
theme: apple-basic
drawings:
  persist: false
mdc: true
layout: intro
transition: null
---

<style>
.slidev-layout > p,
.slidev-layout > ul,
.slidev-layout > ol {
  font-size: 1.45rem;
}

.slidev-layout > ul ul,
.slidev-layout > ol ol {
  font-size: 0.92em;
}
</style>

# NixOSでプログラマにとって超快適なMinecraftサーバーを構築してみる

---

# 自己紹介

<div class="flex justify-center mt-0 pt-0">
  <div class="pt-6 pb-24 px-24 text-center flex flex-col items-center">
    <img src="https://cdn.nostrcheck.me/1beecee55f69ebc2890403606f28b5e8ebbab23d226730e12b4bf762d29d2162/0c485cbf8db44882b730926366e545d211145cf1fee8b19909fa192e0e6d0443.webp" class="rounded-full w-48 h-48 mx-auto" />
    <h2 class="text-gray-500 font-bold mt-4">@akazdayo</h2>
    <h1 class="mt-2">あかず</h1>
  </div>
  <div class="pt-6 pb-24 px-24 text-left overflow-hidden">
    <h2>未踏ジュニアでやってた</h2>
    <div class="text-left">
      <ul>
        <li>aikyoを作っていた</li>
        <li>マルチパーティAIエージェントの<br/>操作とかは話せそう</li>
      </ul>
    </div>
    <h2>趣味</h2>
    <div class="text-left">
      <ul>
        <li>技術
          <ul>
            <li>Nix</li>
            <li>Nostr</li>
            <li>TTSで遊んでるかも</li>
          </ul>
        </li>
        <li>ゲーム
          <ul>
            <li>osu!</li>
            <li>VRChat</li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</div>

---
layout: two-cols
---

# Nixとかいうやつ

- パッケージマネージャー
- 設定をコードで書ける
- 同じ設定から何度でも再現できる
- NixOSはそれをOS全体に広げたもの

::right::

<img src="https://brand.nixos.org/logos/nixos-logo-default-gradient-black-regular-vertical-recommended.svg" class="w-72 mx-auto mt-10"/>

---
layout: statement
---

# 例を出すと...

---

## 例えばGitなら

```bash
$ git lfs install

$ git config --global user.name "akazdayo"
$ git config --global user.email "82073147+akazdayo@users.noreply.github.com"
$ git config --global init.defaultBranch "main"
```

---

## Nixなら...

```nix
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "akazdayo";
        email = "82073147+akazdayo@users.noreply.github.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
```

---
layout: statement
---

# 本題: マイクラなら

---
layout: full
---

<DebianMinecraftChaos />

<div class="absolute top-6 right-8 text-gray-500 text-5xl">
  ※アンフェアな比較
</div>

---

## Nixなら...

```nix
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.fabric-smp = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_5;
      jvmOpts = "-Xms4G -Xmx8G";

      serverProperties = {
        server-port = 25565;
        motd = "NixOS Fabric Minecraft Server";
        gamemode = "survival";
        difficulty = "normal";
        max-players = 20;
        white-list = false;
        online-mode = true;
        view-distance = 10;
        simulation-distance = 10;
      };
    };
  };
```

---
layout: statement
---

# これが楽しいところ

---
layout: statement
---

# じゃあみんな入っていいよ〜☺️

---

<div class="h-full flex items-center justify-center">
  <div class="w-[720px] max-w-full flex flex-col gap-8 text-3xl">
    <div class="flex items-end gap-4">
      <div class="w-14 h-14 rounded-full bg-gray-800 text-white flex items-center justify-center text-xl font-bold shrink-0">A</div>
      <div>
        <div class="text-gray-500 text-base mb-2">Aさん</div>
        <div class="bg-white rounded-3xl rounded-bl-md px-7 py-5 shadow-sm border border-gray-100">
          ホワイトリスト追加してほしい
        </div>
      </div>
    </div>
    <div class="flex items-end justify-end gap-4">
      <div>
        <div class="text-right text-gray-500 text-base mb-2">私</div>
        <div class="bg-green-500 text-white rounded-3xl rounded-br-md px-7 py-5 shadow-sm">
          うーん
        </div>
      </div>
      <div class="w-14 h-14 rounded-full bg-green-600 text-white flex items-center justify-center text-xl font-bold shrink-0">私</div>
    </div>
  </div>
</div>

---

# whitelistに追加して欲しい？PRを立てよう

<div class="grid grid-cols-2 gap-6 pt-10">
  <a href="https://github.com/akazdayo/nix-configs/pull/29" target="_blank">
    <img
      src="https://opengraph.githubassets.com/nix-minecraft-lt/akazdayo/nix-configs/pull/29"
      alt="akazdayo/nix-configs pull request 29"
      class="w-full rounded-lg shadow-lg border border-gray-200"
    />
  </a>
  <a href="https://github.com/akazdayo/nix-configs/pull/31" target="_blank">
    <img
      src="https://opengraph.githubassets.com/nix-minecraft-lt-31/akazdayo/nix-configs/pull/31"
      alt="akazdayo/nix-configs pull request 31"
      class="w-full rounded-lg shadow-lg border border-gray-200"
    />
  </a>
</div>

---

# マイクラサーバー管理者ってめんどくさい...

例えば...

- MODいれてー
- サーバー落ちたんだけど
- 俺のことホワイトリスト, OP追加して
- プロキシの設定して

---

# いやいや、そんなのお前がやれよ

ができます

- PRおくれ〜〜
- Issue立てといて〜
- レビューしといて〜
- これValidなのー

---

# MODも入れれる

<div class="flex flex-col gap-5 pt-2">
  <div class="grid grid-cols-2 gap-5">
    <a href="https://github.com/akazdayo/nix-configs/pull/36" target="_blank">
      <img
        src="https://opengraph.githubassets.com/nix-minecraft-lt-36/akazdayo/nix-configs/pull/36"
        alt="akazdayo/nix-configs pull request 36"
        class="w-full rounded-lg shadow-md border border-gray-200"
      />
    </a>
    <a href="https://github.com/akazdayo/nix-configs/pull/37" target="_blank">
      <img
        src="https://opengraph.githubassets.com/nix-minecraft-lt-37/akazdayo/nix-configs/pull/37"
        alt="akazdayo/nix-configs pull request 37"
        class="w-full rounded-lg shadow-md border border-gray-200"
      />
    </a>
  </div>
  <a href="https://github.com/akazdayo/nix-configs/pull/20" target="_blank" class="w-1/2 self-center">
    <img
      src="https://opengraph.githubassets.com/nix-minecraft-lt-20/akazdayo/nix-configs/pull/20"
      alt="akazdayo/nix-configs pull request 20"
      class="w-full rounded-lg shadow-md border border-gray-200"
    />
  </a>
</div>

---
layout: statement
---

# Nixは世界を救うのでみんな使おう
