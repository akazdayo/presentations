#let border = rgb("#444444")

#let rule() = line(length: 100%, stroke: 0.8pt + border)

#let heading-prefix(level) = if level == 1 {
  [#sym.hash]
} else {
  [#sym.hash#sym.hash]
}

#let section(title, body, level: 1) = block(
  width: 100%,
  inset: (x: 2.5mm, y: 1mm),
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
