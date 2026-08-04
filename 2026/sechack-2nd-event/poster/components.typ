#let border = rgb("#444444")
#let muted = rgb("#555555")

#let rule() = line(length: 100%, stroke: 0.8pt + border)

#let heading-prefix(number) = [#number.]

#let key(body) = text(weight: "bold")[
  #underline(stroke: 0.7pt + border, body)
]

#let diagram(number, title, path, width: 100%, note: none) = block(
  width: 100%,
  breakable: false,
)[
  #text(
    size: 9.2pt,
    weight: "bold",
    fill: border,
  )[#("図" + str(number))　#title]
  #v(0.7mm)
  #align(center)[#image(path, width: width)]
  #if note != none {
    v(0.6mm)
    text(size: 7.2pt, fill: muted)[*注：* #note]
  }
]

#let section(number, title, body, level: 1) = block(
  width: 100%,
  inset: (x: 1.2mm, y: 0.4mm),
)[
  #text(
    size: 14pt,
    weight: "bold",
  )[
    #heading-prefix(number) #h(1mm) #title
  ]
  #v(-1.8mm)
  #if level == 1 {
    rule()
  }
  #v(if level == 1 { 1mm } else { 0.8mm })
  #body
]
