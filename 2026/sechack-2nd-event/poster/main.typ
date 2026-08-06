#import "@preview/zebra:0.1.0": qrcode
#import "components.typ": *

#set page(
  paper: "a0",
  margin: (x: 18mm, y: 16mm),
)

#set text(
  font: "IPAGothic",
  size: 36pt,
  fill: rgb("#222222"),
)

#set par(justify: false, leading: 0.54em)
#set heading(numbering: none)
#show strong: set text(weight: "bold", stroke: 0.8pt + rgb("#222222"))

#block(inset: (x: 4mm, y: 0mm))[
  #grid(
    columns: (1fr, 124mm),
    column-gutter: 8mm,
    align: (left, top),
    [
      #text(
        size: 72pt,
        weight: "bold",
        tracking: -0.6pt,
      )[
        複数ビルド結果を用いた#linebreak()
        Nix Binary Cacheの信頼性評価
      ]
      #v(3.2mm)
      #text(size: 44pt, weight: "bold")[野田蒼馬]
      #h(6mm)
      #text(size: 38pt, fill: muted)[N高等学校二年]
    ],
    [
      #align(center)[
        #qrcode(
          "https://github.com/akazdayo/reproductive-nix-cache",
          quiet-zone: true,
          background-fill: white,
          width: 72mm,
        )
        #v(2mm)
        #text(size: 29.6pt, weight: "bold", fill: muted)[
          #link("https://github.com/akazdayo/reproductive-nix-cache")[
            実装・検証コード（GitHub）
          ]
        ]
      ]
    ],
  )

  #v(2.4mm)
  #rule()
  #v(2.4mm)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 8mm,
    align: (left, top),
    [
      #section(
        1,
        [目指す世界],
        [
          「信頼する・しない」の二択から、#key[証拠に基づく信頼のグラデーションを作ること]を中心に据える。

          誰が配布したかではなく、#key[どのような証拠があるか]で判断できるようにする。特定の巨大なBinary Cacheだけに依存せず、多様なCacheを安心して利用できるNixエコシステムを実現する。

          #strong[盲目的な信頼をNixのエコシステムから除去し、単一障害点のない持続可能なNixのエコシステムを構築する。]
        ],
      )

      #section(
        2,
        [背景 Nixとは],
        [
          Nixは、同じ入力から同じビルド結果を得ることを重視したパッケージ管理・ビルドシステムである。Nixを使用したNixOSでは、OSの設定や導入するソフトウェアをコードとして管理でき、同じ設定から同等の環境を再構築できる。

          この再現性を高めるため、Nixは外部環境の影響を抑えたサンドボックス内でビルドを行う。しかし、依存するソフトウェアも含めてビルドするため、処理に長い時間がかかり、ディスク容量も消費する。

          そこでNixでは、あらかじめビルドされた成果物を取得できる#key[Binary Cache]が利用される。
        ],
      )

      #section(
        3,
        [現行の信頼モデルと課題],
        [
          #strong[現行の信頼モデルには以下のような課題がある。]
          - 信頼判断が鍵単位の「信頼する・しない」に限られる
          - 署名鍵が侵害されると、不正な成果物も正当と判断され得る
          - 利用実績のある#key[大規模なCacheへ信頼が集中]する
          #v(2mm)
          Binary Cacheは、あらかじめビルドされた成果物を署名と共にサーバーへ保存する仕組みである。利用者は自分でビルドせずに成果物をダウンロードできるため、ビルド時間を大幅に短縮できる。ただし、成果物の正当性は主に#key[Cache運営者の署名鍵を信頼]して判断することになる。
          #v(3.2mm)
          #diagram(
            1,
            [署名鍵を基準とする現行の信頼モデル],
            "../../../shared/diagrams/sechack-nix-binary-cache/existing-method.png",
            width: 82%,
            note: [A〜CはCache配布者。利用者は取得後、署名者が信頼リストに含まれるかを検証する。],
          )
        ],
      )
    ],
    [
      #section(
        4,
        [提案するアプローチ],
        [
          #text(size: 31pt, weight: "bold")[現行方式との比較]
          #v(2mm)
          #text(size: 24pt)[
            #table(
              columns: (2.9fr, 0.48fr, 0.48fr, 3fr),
              inset: (x: 1.8mm, y: 1.4mm),
              stroke: 1.2pt + border,
              align: (left, center, center, left),
              table.header([*課題*], [*現行*], [*提案*], [*説明*]),
              [信頼判断が鍵単位の*「信頼する・しない」に限られてしまう*],
              [×],
              [◎],
              [ビルド証拠によって*信頼にグラデーション*ができる],

              [署名鍵が侵害されると、不正な成果物も*正当と判断され得る*],
              [×],
              [◎],
              [そもそも署名鍵に*信頼を置かない*],

              [利用実績のある*大規模なCacheへ信頼が集中*する],
              [△],
              [△],
              [ローカルで証明を検証可能なのでサーバーは比較的分散できるが、根本的な問題は解決しない],
            )
          ]
          #v(3mm)
          Binary Cacheの成果物を署名鍵だけに頼らず評価するため、#key[複数のコンピュータでビルド]を実行し、その結果をサーバーに記録する。

          ビルドの際、現状は以下の手法を用いて#key[実行したことの証拠]を実装できると考えている。
          - CPUにおけるTrusted Execution Environmentを用いた実行証明
          - Commit-Reveal
            - Commit = SHA256(ビルド証拠 && Salt)
          #v(3.2mm)
          #diagram(
            2,
            [複数のビルド証拠を用いる提案モデル],
            "../../../shared/diagrams/sechack-nix-binary-cache/proposed-method.png",
            width: 76%,
            note: [A〜Cは独立した検証者。出力ハッシュと実行証拠を蓄積し、利用者が取得前に評価する。],
          )
        ],
      )

      #section(
        5,
        [入力と成果物の一致を検証する],
        [
          利用者が確かめたいのは、#key[指定した入力に対応する成果物]である。たとえばGoogle Chromeを導入しようとしたのに、Chromiumへすり替えられるのは困る。

          本研究はマルウェア判定ではなく、#key[指定した入力から得られるはずの成果物との一致]を確かめる。マルウェア検出はVirusTotalなどの専用サービスに任せる方が効率的で現実的な可能性が高い。
        ],
      )

      #section(
        6,
        [脅威モデル],
        [
          現状は以下を想定している。
          - Sybil Attack
            - 複数のビルダーを装い、一致数と信頼スコアを水増しする。
          - TEE侵害・Attestation偽装
            - TEEの脆弱性を悪用し、不正な成果物を正当と偽る。
          - 証拠のリプレイ
            - 証拠を再利用・複製し、独立した証拠数を水増しする。
        ],
      )
    ],
  )
]
