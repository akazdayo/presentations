<script setup lang="ts">
const commands = [
  { text: "$ sudo apt update", x: 46, y: 98, rot: -1.5, delay: 0.05 },
  {
    text: "$ sudo apt install -y curl jq openjdk-21-jre-headless",
    x: 258,
    y: 86,
    rot: 1,
    delay: 0.1,
  },
  {
    text: "$ sudo useradd --system minecraft",
    x: 602,
    y: 102,
    rot: -0.5,
    delay: 0.15,
  },
  {
    text: "$ sudo mkdir -p /opt/minecraft/server",
    x: 72,
    y: 158,
    rot: 1.5,
    delay: 0.2,
  },
  {
    text: "$ sudo chown minecraft:minecraft /opt/minecraft/server",
    x: 420,
    y: 156,
    rot: -1.5,
    delay: 0.25,
  },
  { text: "$ cd /opt/minecraft/server", x: 756, y: 166, rot: 2, delay: 0.3 },
  {
    text: "$ curl version_manifest_v2.json",
    x: 34,
    y: 226,
    rot: -2,
    delay: 0.35,
  },
  {
    text: "$ jq '.versions[] | select(.type==\"release\")'",
    x: 310,
    y: 228,
    rot: 0.5,
    delay: 0.4,
  },
  { text: "$ curl server.jar", x: 720, y: 230, rot: -1, delay: 0.45 },
  { text: "$ echo eula=true > eula.txt", x: 94, y: 300, rot: 2, delay: 0.5 },
  { text: "$ vim server.properties", x: 378, y: 296, rot: -1.5, delay: 0.55 },
  { text: "enable-command-block=true", x: 682, y: 302, rot: 1.5, delay: 0.6 },
  { text: "online-mode=true", x: 26, y: 368, rot: 0.5, delay: 0.65 },
  { text: "white-list=true", x: 238, y: 366, rot: -2, delay: 0.7 },
  { text: "motd=akazdayo server", x: 452, y: 370, rot: 1.5, delay: 0.75 },
  { text: "$ vim whitelist.json", x: 708, y: 374, rot: -1.5, delay: 0.8 },
  {
    text: '{"name":"akazdayo","uuid":"0000..."}',
    x: 68,
    y: 438,
    rot: 1.5,
    delay: 0.85,
  },
  { text: "$ vim ops.json", x: 420, y: 440, rot: -1, delay: 0.9 },
  {
    text: '{"level":4,"bypassesPlayerLimit":false}',
    x: 628,
    y: 436,
    rot: 2,
    delay: 0.95,
  },
  {
    text: "$ sudo vim /etc/systemd/system/minecraft.service",
    x: 24,
    y: 510,
    rot: -1.5,
    delay: 1.0,
  },
  {
    text: "[Unit] Description=Minecraft Server",
    x: 464,
    y: 506,
    rot: 1,
    delay: 1.05,
  },
  { text: "[Service] User=minecraft", x: 744, y: 510, rot: -2, delay: 1.1 },
  {
    text: "WorkingDirectory=/opt/minecraft/server",
    x: 84,
    y: 578,
    rot: 1,
    delay: 1.15,
  },
  {
    text: "ExecStart=/usr/bin/java -Xms2G -Xmx2G -jar server.jar nogui",
    x: 380,
    y: 574,
    rot: -1,
    delay: 1.2,
  },
  { text: "$ sudo ufw allow 25565/tcp", x: 56, y: 646, rot: -1.5, delay: 1.25 },
  {
    text: "$ sudo systemctl daemon-reload",
    x: 342,
    y: 650,
    rot: 1.5,
    delay: 1.3,
  },
  {
    text: "$ sudo systemctl enable --now minecraft",
    x: 624,
    y: 646,
    rot: -1,
    delay: 1.35,
  },
  { text: "$ journalctl -u minecraft -f", x: 760, y: 586, rot: 2, delay: 1.4 },
];
</script>

<template>
  <div class="debian-chaos">
    <h2>何も入ってないDebianでやるなら...</h2>
    <code
      v-for="command in commands"
      :key="command.text"
      class="cmd"
      :style="{
        left: `${command.x}px`,
        top: `${command.y}px`,
        '--rot': `${command.rot}deg`,
        '--delay': `${command.delay}s`,
      }"
    >
      {{ command.text }}
    </code>
  </div>
</template>

<style scoped>
.debian-chaos {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background: #fff;
}

.debian-chaos h2 {
  position: absolute;
  z-index: 30;
  top: 24px;
  left: 44px;
  margin: 0;
  color: #1f2937;
  font-size: 34px;
  font-weight: 700;
}

.cmd {
  position: absolute;
  z-index: 10;
  display: block;
  max-width: 360px;
  padding: 7px 10px;
  border: 1px solid rgb(229 231 235 / 0.95);
  border-radius: 6px;
  box-shadow: 0 8px 20px rgb(15 23 42 / 0.08);
  background: rgb(249 250 251 / 0.96);
  color: #374151;
  font-size: 13px;
  line-height: 1.15;
  white-space: nowrap;
  opacity: 0;
  transform: translateY(22px) rotate(var(--rot)) scale(0.82);
  animation: cmd-pop 0.3s cubic-bezier(0.2, 1.35, 0.3, 1) forwards;
  animation-delay: var(--delay);
}

.cmd:nth-of-type(3n) {
  background: rgb(243 244 246 / 0.96);
}

.cmd:nth-of-type(3n + 1) {
  background: rgb(255 255 255 / 0.98);
}

.cmd:nth-of-type(3n + 2) {
  background: rgb(238 242 255 / 0.88);
}

@keyframes cmd-pop {
  0% {
    opacity: 0;
    transform: translateY(26px) rotate(0deg) scale(0.82);
  }

  70% {
    opacity: 1;
    transform: translateY(-3px) rotate(var(--rot)) scale(1.02);
  }

  100% {
    opacity: 1;
    transform: translateY(0) rotate(var(--rot)) scale(1);
  }
}
</style>
