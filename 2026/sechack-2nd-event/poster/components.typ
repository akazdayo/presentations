#let border = rgb("#444444")
#let light = rgb("#f7f7f7")
#let accent = rgb("#315f8c")

#let rule() = line(length: 100%, stroke: 0.8pt + border)

#let heading-prefix(level) = if level == 1 {
  [#sym.hash]
} else {
  [#sym.hash#sym.hash]
}

#let section(title, body, level: 1) = block(
  width: 100%,
  inset: (x: 2.5mm, y: 1.5mm),
)[
  #text(
    size: 14pt,
    weight: "bold",
  )[
    #heading-prefix(level) #h(1.2mm) #title
  ]
  #v(-1.5mm)
  #if level == 1 {
    rule()
  }
  #v(if level == 1 { 1.5mm } else { 1.2mm })
  #body
]

#let flow-box(body) = rect(
  width: 100%,
  radius: 1.2mm,
  inset: (x: 2mm, y: 1.5mm),
  fill: light,
  stroke: 0.5pt + rgb("#c8d0d8"),
)[
  #align(center + horizon)[
    #text(size: 9pt, weight: "bold")[#body]
  ]
]

#let flow-arrow() = align(center)[
  #text(size: 13pt, weight: "bold", fill: accent)[↓]
]

#let cache-request-flow() = align(center)[
  #flow-box[利用者]
  #flow-arrow()
  #flow-box[キャッシュサーバー]
  #flow-arrow()
  #flow-box[成果物＋署名]
  #flow-arrow()
  #flow-box[署名を照合]
  #flow-arrow()
  #flow-box[利用]
]

#let evidence-flow() = align(center)[
  #flow-box[入力]
  #flow-arrow()
  #rect(
    width: 100%,
    radius: 1.2mm,
    inset: 2mm,
    fill: rgb("#eef3f8"),
    stroke: 0.5pt + rgb("#c8d0d8"),
  )[
    #align(center)[
      #text(size: 9pt, weight: "bold")[複数の独立したビルダー]
      #v(1mm)
      #text(size: 8.5pt)[Builder A　・　Builder B　・　Builder C]
    ]
  ]
  #flow-arrow()
  #flow-box[ビルド証拠]
  #flow-arrow()
  #flow-box[台帳に集約]
  #flow-arrow()
  #flow-box[信頼スコア]
]

#let bullet(body) = block(width: 100%)[
  #grid(
    columns: (4mm, 1fr),
    column-gutter: 1mm,
    align: (left, top),
    [#text(size: 12pt, weight: "bold", fill: accent)[・]], [#body],
  )
]
