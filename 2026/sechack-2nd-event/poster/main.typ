#import "components.typ": *

#set page(
  paper: "a4",
  margin: (x: 8mm, y: 8mm),
)

#set text(
  font: "IPAGothic",
  size: 9pt,
  fill: rgb("#222222"),
)

#set par(justify: false, leading: 0.72em)
#set heading(numbering: none)

#block(inset: 4mm)[
  #align(left)[
    #text(
      size: 14pt,
      weight: "bold",
    )[複数ビルド結果を用いたNix Binary Cacheの信頼性評価]
    #v(2mm)
    #text(size: 13pt)[著者: 野田蒼馬]
    #linebreak()
    #text(size: 11pt, fill: rgb("#555555"))[世界観駆動コース]
  ]

  #v(2mm)
  #rule()
  #v(2mm)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1mm,
    align: (left, top),
    [
      #section(
        [背景],
        [
          #bullet[Nixは再現性を重視するが、ビルドには時間がかかる。]
          #v(0.7mm)
          #bullet[Binary Cacheを使えば、ビルド済み成果物を取得できる。]
        ],
      )

      #v(0.5mm)

      #section(
        [BinaryCache],
        [
          #bullet[あらかじめビルドされた成果物を署名と共にサーバーに保存する。]
          #v(0.7mm)
          #bullet[利用者は自分でビルドせず、成果物をダウンロードする。]
          #v(0.7mm)
          #bullet[ビルド時間を大幅に短縮できる。]
          #v(0.7mm)
          #bullet[成果物の正当性は、主にCache運営者の署名鍵を信頼して判断する。]
          #v(0.5mm)
          #align(center)[
            #image(
              "../assets/existing-method.png",
              width: 100%,
            )
          ]
        ],
      )

      #v(0.5mm)

      #section(
        [何が嬉しいか],
        [
          #bullet[署名鍵やCache運営者だけを無条件に信頼しなくてよくなる。]
          #v(0.7mm)
          #bullet[利用者が証拠をもとに成果物を選択できる。]
          #v(0.7mm)
          #bullet[小規模・個人運営のCacheも利用しやすくなる。]
          #v(0.7mm)
          #bullet[自分で再ビルドするコストを減らしながら信頼性を確認できる。]
        ],
      )
    ],
    [
      #section(
        [課題],
        [
          #bullet[ただし成果物の正当性は、主に署名鍵への信頼に依存する。]
          #v(0.7mm)
          #bullet[正しい入力から生成されたかは、再ビルドしないと確認しにくい。]
          #v(0.7mm)
          #bullet[そのため、小規模なCacheは利用者から信頼されにくい。]
        ],
      )

      #v(0.5mm)

      #section(
        [提案するアプローチ],
        [
          #bullet[Nix Binary Cacheの成果物を、署名鍵だけに頼らず評価する。]
          #v(0.7mm)
          #bullet[複数のコンピュータで再ビルドし、結果を比較する。]
          #v(0.7mm)
          #bullet[ビルド環境・入力・出力などの実行証拠を記録する。]
          #v(0.7mm)
          #bullet[出力の一致数や証拠の独立性から信頼スコアを算出する。]
          #v(0.7mm)
          #bullet[小規模・個人運営のCacheも安心して使える環境を目指す。]
          #v(0.5mm)
          #align(center)[
            #image(
              "../assets/proposed-method.png",
              width: 100%,
            )
          ]
        ],
      )

      #v(0.5mm)

      #section(
        [目指す世界],
        [
          #bullet[「信頼する・しない」の二択ではなく、信頼にグラデーションを持たせる。]
          #v(0.7mm)
          #bullet[誰が配布したかではなく、どのような証拠があるかで判断できる。]
          #v(0.7mm)
          #bullet[特定の巨大なBinary Cacheだけに依存しない。]
          #v(0.7mm)
          #bullet[多様なCacheを安心して利用できるNixエコシステムを実現する。]
        ],
      )
    ],
  )
]
