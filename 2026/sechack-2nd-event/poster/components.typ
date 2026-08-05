#let border = rgb("#444444")
#let muted = rgb("#555555")

#let rule() = line(length: 100%, stroke: 3.2pt + border)

#let heading-prefix(number) = [#number.]

#let key(body) = text(weight: "bold")[
  #underline(stroke: 2.8pt + border, body)
]

#let diagram(number, title, path, width: 100%, note: none) = block(
  width: 100%,
  breakable: false,
)[
  #text(
    size: 36.8pt,
    weight: "bold",
    fill: border,
  )[#("図" + str(number))　#title]
  #v(2.8mm)
  #align(center)[#image(path, width: width)]
  #if note != none {
    v(2.4mm)
    text(size: 28.8pt, fill: muted)[*注：* #note]
  }
]

#let section(number, title, body, level: 1) = block(
  width: 100%,
  inset: (x: 4.8mm, y: 1.6mm),
)[
  #text(
    size: 56pt,
    weight: "bold",
  )[
    #heading-prefix(number) #h(4mm) #title
  ]
  #v(-7.2mm)
  #if level == 1 {
    rule()
  }
  #v(if level == 1 { 4mm } else { 3.2mm })
  #body
]
