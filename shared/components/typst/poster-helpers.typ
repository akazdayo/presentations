#import "@preview/zebra:0.1.0": qrcode
#import "@preview/mmdr:0.2.1": mermaid-svg

#let border = rgb("#444444")
#let light = rgb("#f7f7f7")

#let rule() = line(length: 100%, stroke: 0.8pt + border)

#let heading-prefix(level) = if level == 1 {
  [#sym.hash]
} else {
  [#sym.hash#sym.hash]
}

#let section(title, body, level: 1) = block(
  width: 100%,
  inset: (x: 4mm, y: 4mm),
)[
  #text(
    size: if level == 1 { 32pt } else { 26pt },
    weight: "bold",
  )[
    #heading-prefix(level) #h(1.2mm) #title
  ]
  #v(if level == 1 { 3mm } else { 2.2mm })
  #if level == 1 {
    rule()
  }
  #v(if level == 1 { 4.5mm } else { 3mm })
  #body
]

#let mini-caption(text-body) = align(center)[
  #text(size: 16pt, fill: rgb("#444444"))[#text-body]
]

#let flow-arrow() = align(center + horizon)[
  #text(size: 28pt, weight: "bold", fill: border)[#sym.arrow.r]
]

#let qr-panel(url, label: "GitHub") = align(center + top)[
  #block(width: 64mm)[
    #align(center)[
      #qrcode(
        url,
        quiet-zone: true,
        background-fill: white,
        width: 46mm,
      )
    ]
    #v(2.5mm)
    #align(center)[
      #text(size: 14pt, fill: rgb("#555555"))[#label]
    ]
    #v(0.8mm)
    #align(center)[
      #text(
        size: 11.5pt,
        fill: rgb("#555555"),
      )[#url]
    ]
  ]
]

#let reference-item(label, body) = block(width: 100%)[
  #set text(size: 18pt)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 3mm,
    align: (left, top),
    [#text(weight: "bold")[#label]], [#body],
  )
]

#let info-card(title, body) = rect(
  width: 100%,
  radius: 1.8mm,
  inset: 3.5mm,
  fill: light,
  stroke: 0.6pt + rgb("#d4d4d4"),
)[
  #text(size: 18pt, weight: "bold", fill: border)[#title]
  #v(1.2mm)
  #body
]

#let compare-head(body) = rect(
  width: 100%,
  radius: 1.2mm,
  inset: (x: 2.2mm, y: 1.8mm),
  fill: border,
)[
  #align(center + horizon)[
    #text(size: 15.5pt, weight: "bold", fill: white)[#body]
  ]
]

#let compare-label(body) = rect(
  width: 100%,
  radius: 1.2mm,
  inset: (x: 2.2mm, y: 1.8mm),
  fill: rgb("#ececec"),
  stroke: 0.5pt + rgb("#d8d8d8"),
)[
  #text(size: 15.5pt, weight: "bold", fill: border)[#body]
]

#let compare-cell(body, fill: white) = rect(
  width: 100%,
  radius: 1.2mm,
  inset: (x: 2.2mm, y: 1.8mm),
  fill: fill,
  stroke: 0.5pt + rgb("#d8d8d8"),
)[
  #text(size: 15.5pt)[#body]
]

#let spec-item(label, body) = block(width: 100%)[
  #set text(top-edge: "cap-height", bottom-edge: "baseline")
  #grid(
    columns: (32mm, 1fr),
    column-gutter: 2mm,
    align: (left, top),
    [
      #text(size: 16pt, weight: "bold", fill: rgb("#555555"))[#label]
    ],
    [
      #text(size: 17pt)[#body]
    ],
  )
]
