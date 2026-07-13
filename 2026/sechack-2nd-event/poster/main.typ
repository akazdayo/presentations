#import "components.typ": *

#set page(
  paper: "a4",
  margin: (x: 8mm, y: 8mm),
)

#set text(
  font: "IPAGothic",
  size: 12pt,
  fill: rgb("#222222"),
)

#set par(justify: false, leading: 0.84em)
#set heading(numbering: none)

#block(inset: 4mm)[
  #align(left)[
    #text(
      size: 14pt,
      weight: "bold",
    )[複数ビルド結果を用いたNix Binary Cacheの信頼性評価]
    #v(3.5mm)
    #text(size: 13pt)[著者: 野田蒼馬]
    #linebreak()
    #text(size: 11pt, fill: rgb("#555555"))[世界観駆動コース]
  ]

  #v(3mm)
  #rule()
  #v(3mm)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 10mm,
    align: (left, top),
    [
      #section(
        [概要],
        [
          Nix Binary Cacheの成果物に対して、複数のビルド結果や実行証拠を集め、信頼性をスコアとして示す仕組みをつくる。
          #parbreak()
          署名鍵を持つ運営者をそのまま信頼するのではなく、成果物にどのような証拠があるかを基準に判断できるようにする。
        ],
      )

      #v(3mm)

      #section(
        [背景・課題],
        [
          #bullet[Nixは、同じ入力から同じ成果物を作ることを目指すビルドシステムである。]
          #v(1mm)
          #bullet[しかし、成果物のハッシュは実際にビルドしなければ確認できない。]
          #v(1mm)
          #bullet[Binary Cacheでは署名を確認して利用するが、署名鍵の所有者が正しい成果物を配布しているとは限らない。]
          #v(1mm)
          #bullet[そのため、小規模なキャッシュや個人運営のキャッシュは信頼されにくい。]
        ],
      )

      #v(3mm)

      #section(
        [Binary Cache],
        [
          ビルド済み成果物をキャッシュサーバーから取得し、署名を確認して利用する。
          #v(2mm)
          #cache-request-flow()
        ],
      )
    ],
    [
      #section(
        [提案するアプローチ],
        [
          複数の独立したビルダーが同じ入力からビルドする。各ビルドの入力ハッシュ・成果物ハッシュ・実行証拠を集め、出力の一致性やビルダーの独立性をもとに、成果物の信頼スコアを計算する。
          #v(2mm)
          #evidence-flow()
        ],
      )

      #v(3mm)

      #section(
        [何が嬉しいか],
        [
          #bullet[利用者は、署名者の名前だけでなく、複数の証拠を見てキャッシュを選べる。]
          #v(1mm)
          #bullet[小規模なキャッシュでも、証拠を積み重ねて信頼を得られる。]
          #v(1mm)
          #bullet[「信頼する／しない」の二択ではなく、用途に応じて判断できる。]
        ],
      )

      #v(3mm)

      #section(
        [目指す世界],
        [
          特定の大規模キャッシュだけに依存せず、多様なBinary Cacheが利用されるNixエコシステムを目指す。
          #parbreak()
          絶対的な安全を謳うのではなく、検証可能な証拠に基づいて、利用者自身が信頼性を判断できる世界を実現する。
        ],
      )
    ],
  )
]
