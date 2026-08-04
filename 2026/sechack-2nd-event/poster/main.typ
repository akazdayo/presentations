#import "@preview/zebra:0.1.0": qrcode
#import "components.typ": *

#set page(
  paper: "a4",
  margin: (x: 4.5mm, y: 4mm),
)

#set text(
  font: "IPAGothic",
  size: 9pt,
  fill: rgb("#222222"),
)

#set par(justify: false, leading: 0.54em)
#set heading(numbering: none)

#block(inset: (x: 1mm, y: 0mm))[
  #grid(
    columns: (1fr, 31mm),
    column-gutter: 2mm,
    align: (left, top),
    [
      #text(
        size: 20pt,
        weight: "bold",
        tracking: -0.15pt,
      )[
        複数ビルド結果を用いた#linebreak()
        Nix Binary Cacheの信頼性評価
      ]
      #v(1.4mm)
      #text(size: 11.5pt, weight: "bold")[野田蒼馬]
      #h(2mm)
      #text(size: 10pt, fill: muted)[N高等学校二年生]
    ],
    [
      #align(center)[
        #qrcode(
          "https://github.com/akazdayo/reproductive-nix-cache",
          quiet-zone: true,
          background-fill: white,
          width: 18mm,
        )
        #v(0.5mm)
        #text(size: 7.4pt, weight: "bold", fill: muted)[
          #link("https://github.com/akazdayo/reproductive-nix-cache")[
            実装・検証コード（GitHub）
          ]
        ]
      ]
    ],
  )

  #v(1mm)
  #rule()
  #v(1mm)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2mm,
    align: (left, top),
    [
      #section(
        1,
        [背景],
        [
          Nixは、同じ入力から同じビルド結果を得ることを重視したパッケージ管理・ビルドシステムである。NixOSでは、OSの設定や導入するソフトウェアをコードとして管理でき、同じ設定から同等の環境を再構築できる。

          この再現性を高めるため、Nixは外部環境の影響を抑えたサンドボックス内でビルドを行う。しかし、依存するソフトウェアも含めてビルドするため、処理に長い時間がかかり、ディスク容量も消費する。

          そこでNixでは、あらかじめビルドされた成果物を取得できる#key[Binary Cache]が利用される。
        ],
      )

      #section(
        2,
        [現行の信頼モデルと課題],
        [
          Binary Cacheは、あらかじめビルドされた成果物を署名と共にサーバーへ保存する仕組みである。利用者は自分でビルドせずに成果物をダウンロードできるため、ビルド時間を大幅に短縮できる。ただし、成果物の正当性は主に#key[Cache運営者の署名鍵を信頼]して判断することになる。
          #v(0.8mm)
          #diagram(
            1,
            [署名鍵を基準とする現行の信頼モデル],
            "../../../shared/diagrams/sechack-nix-binary-cache/existing-method.png",
            width: 82%,
            note: [A〜CはCache配布者。利用者は取得後、署名者が信頼リストに含まれるかを検証する。],
          )
          #v(0.5mm)
          現行の信頼モデルには以下のような課題がある。
          - 信頼判断が鍵単位の「信頼する・しない」に限られる
          - 署名鍵が侵害されると、不正な成果物も正当と判断され得る
          - 結果として、利用実績のある#key[大規模なCacheへ信頼が集中]する
        ],
      )

      #section(
        3,
        [目指す世界],
        [
          署名鍵を「信頼する・しない」という二択ではなく、#key[ビルド証拠による信頼のグラデーション]を持たせる。

          誰が配布したかではなく、#key[どのような証拠があるか]で判断できるようにする。特定の巨大なBinary Cacheだけに依存せず、多様なCacheを安心して利用できるNixエコシステムを実現する。
        ],
      )
    ],
    [
      #section(
        4,
        [提案するアプローチ],
        [
          Binary Cacheの成果物を署名鍵だけに頼らず評価するため、#linebreak()
          #key[複数のコンピュータで再ビルド]して結果を記録する。その際、ビルド環境・入力・出力などの実行証拠を記録し、出力の一致数や証拠の独立性から#key[信頼スコア]を算出する。これによって、小規模・個人運営のCacheも安心して使える環境を目指す。
          #v(0.8mm)
          #diagram(
            2,
            [複数のビルド証拠を用いる提案モデル],
            "../../../shared/diagrams/sechack-nix-binary-cache/proposed-method.png",
            width: 88%,
            note: [A〜Cは独立した検証者。出力ハッシュと実行証拠を蓄積し、利用者が取得前に評価する。],
          )
          #v(0.5mm)
          以下をスコアリング指標として検討しているが、現状はまだ固まっていない。
          - 出力の一致性
            - 同じ入力から、同じ出力が出された数
          - ビルドした証拠の有効性
            - おそらく、TEE Attestationやゼロ知識証明が利用できる
        ],
      )

      #section(
        5,
        [なぜ成果物の一致を確かめるのか],
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
