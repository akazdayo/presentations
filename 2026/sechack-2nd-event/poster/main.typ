#import "@preview/zebra:0.1.0": qrcode
#import "@preview/mmdr:0.2.1": mermaid-svg
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
    columns: (1fr, 104mm),
    column-gutter: 8mm,
    align: (left, top),
    [
      #text(
        size: 64pt,
        weight: "bold",
        tracking: -0.6pt,
      )[
        複数ビルド結果を用いた#linebreak()
        Nix Binary Cacheの信頼性評価
      ]
      #v(2mm)
      #text(size: 40pt, weight: "bold")[野田蒼馬]
      #h(5mm)
      #text(size: 34pt, fill: muted)[N高等学校二年]
    ],
    [
      #align(center)[
        #qrcode(
          "https://github.com/akazdayo/reproductive-nix-cache",
          quiet-zone: true,
          background-fill: white,
          width: 56mm,
        )
        #v(1.2mm)
        #text(size: 26pt, weight: "bold", fill: muted)[
          #link("https://github.com/akazdayo/reproductive-nix-cache")[
            実装・検証コード（GitHub）
          ]
        ]
      ]
    ],
  )

  #v(1.6mm)
  #rule()
  #v(1.6mm)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 8mm,
    align: (left, top),
    [
      #section(
        1,
        [背景],
        [],
      )

      #section(
        "1.1",
        [Nixとは],
        [
          Nixは、同じ入力から同じビルド結果を得ることを重視したパッケージ管理・ビルドシステムである。Nixを使用したNixOSでは、OSの設定や導入するソフトウェアをコードとして管理でき、同じ設定から同等の環境を再構築できる。

          この再現性を高めるため、Nixは外部環境の影響を抑えたサンドボックス内でビルドを行う。しかし、依存するソフトウェアも含めてビルドするため、処理に長い時間がかかり、ディスク容量も消費する。

          そこでNixでは、あらかじめビルドされた成果物を取得できる#key[Binary Cache]が利用される。
        ],
        level: 2,
      )

      #section(
        "1.2",
        [目指す世界],
        [
          「信頼する・しない」の二択から、#key[証拠に基づく信頼のグラデーションを作ること]を中心に据える。

          誰が配布したかではなく、#key[どのような証拠があるか]で判断できるようにする。特定の巨大なBinary Cacheだけに依存せず、多様なCacheを安心して利用できるNixエコシステムを実現する。

          #text(
            size: 43.2pt,
            weight: "bold",
            fill: rgb("#c62828"),
            stroke: 0.8pt + rgb("#c62828"),
          )[
            盲目的な信頼, 単一障害点の無い持続可能な#linebreak()Nixエコシステムの構築を目指す
          ]
        ],
        level: 2,
      )

      #section(
        2,
        [現行の信頼モデルと課題],
        [
          #strong[現行の信頼モデルには以下のような課題がある。]
          #v(1.2mm)
          #block(
            width: 100%,
            inset: (x: 3mm, y: 2.4mm),
            stroke: 2.4pt + rgb("#c62828"),
            radius: 2mm,
          )[
            - 信頼判断が鍵単位の「信頼する・しない」に限られる
            - 署名鍵が侵害されると、不正な成果物も正当と判断され得る
            - 利用実績のある#key[大規模なCacheへ信頼が集中]する
          ]
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
        3,
        [提案],
        [
          #section(
            "3.1",
            [アプローチ],
            [
              #text(fill: rgb("#c62828"))[
                Binary Cacheの成果物を署名鍵だけに頼らず評価するために、#text(
                  weight: "bold",
                  stroke: 0.8pt + rgb("#c62828"),
                )[
                  #underline(stroke: 2.8pt + rgb("#c62828"))[複数のコンピュータでビルド]
                ]を実行し、その結果をサーバーに記録する。
              ]

              現状は以下の手法を組み合わせることを考えている。
              - TEE(Trusted Execution Environment)による#key[実行証明]
                - 入力・ビルド環境・出力を結びつける
              - Commit-Revealによる#key[後追い提出の抑止]
                - Commit = SHA256(ビルド証拠 && Salt)
              #v(3mm)
              #grid(
                columns: (1fr, 1fr),
                column-gutter: 5mm,
                align: (left, top),
                [
                  #diagram(
                    2,
                    [複数のビルド証拠を用いる提案モデル],
                    "../../../shared/diagrams/sechack-nix-binary-cache/proposed-method.png",
                    width: 100%,
                  )
                ],
                [
                  #align(center)[
                    #text(
                      size: 36.8pt,
                      weight: "bold",
                      fill: border,
                    )[図3　Commit-Reveal の検証フロー]
                    #v(2.8mm)
                    #image(
                      bytes(
                        mermaid-svg(
                          "sequenceDiagram\n"
                            + "    participant A as Builder A\n"
                            + "    participant B as Builder B\n"
                            + "    participant C as Coordinator\n"
                            + "\n"
                            + "    A->>C: Commit: H(result + nonce)\n"
                            + "    B->>C: Commit: H(result + nonce)\n"
                            + "\n"
                            + "    Note over A,C: All commits received\n"
                            + "\n"
                            + "    A->>C: Reveal: result + nonce\n"
                            + "    B->>C: Reveal: result + nonce\n"
                            + "\n"
                            + "    C->>C: H(result + nonce) == hash ?\n"
                            + "    C->>C: Compare results\n",
                          layout: (node_spacing: 28),
                        ),
                      ),
                      format: "svg",
                      width: 100%,
                    )
                  ]
                ],
              )
            ],
            level: 2,
          )

          #section(
            "3.2",
            [現行方式との比較],
            [
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
                  [○],
                  [署名鍵以外の証拠を加え、*署名鍵だけへの依存を軽減*する],

                  [利用実績のある*大規模なCacheへ信頼が集中*する],
                  [△],
                  [△],
                  [ローカルで証明を検証可能なのでサーバーは比較的分散できるが、根本的な問題は解決しない],
                )
              ]
            ],
            level: 2,
          )

        ],
      )
    ],
  )

  #v(1.6mm)
  #block(
    width: 100%,
    inset: (x: 4.8mm, y: 0.6mm),
  )[
    #text(size: 24pt)[#strong[参考文献]]
    #v(0.5mm)
    #text(size: 20pt)[
      #set par(leading: 0.16em)
      \[1\] A. Hoese, “Trustix: Distributed Trust and Reproducibility Tracking for Binary Caches,” Tweag, 2020.
      #linebreak()
      \[2\] J. Malka and A. Engelen, “Lila: Decentralized Build Reproducibility Monitoring for the Functional Package Management Model,” Proc. MSR ’26, 2026. doi: 10.1145/3793302.3793328.
      #linebreak()
      \[3\] D. Hugenroth, M. Lins, R. Mayrhofer, and A. R. Beresford, “Attestable Builds: Compiling Verifiable Binaries on Untrusted Systems Using Trusted Execution Environments,” Proc. ACM CCS ’25, pp. 4514–4528, 2025. doi: 10.1145/3719027.3765128.
    ]
  ]
]
