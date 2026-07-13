#import "@preview/zebra:0.1.0": qrcode
#import "@preview/mmdr:0.2.1": mermaid-svg

#set page(
  paper: "a0",
  margin: (x: 8mm, y: 8mm),
)

#set text(
  font: "IPAGothic",
  size: 22pt,
  fill: rgb("#222222"),
)

#set par(justify: false, leading: 0.84em)
#set heading(numbering: none)

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

#let flow-image(path, height: 78mm) = block(width: 100%, height: height)[
  #align(center + horizon)[
    #image(path, height: height)
  ]
]

#let demo-flow(image-height: 68mm) = align(center)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    rows: (auto, auto),
    column-gutter: 2.5mm,
    row-gutter: 1.2mm,
    align: (center, center),
    [
      #flow-image("assets/cam2_detected.png", height: image-height)
    ],
    [#flow-arrow()],
    [
      #flow-image("assets/cam2_metrabs_3d_plot.png", height: image-height)
    ],
    [#flow-arrow()],
    [
      #flow-image("assets/vrchat-tracking-demo.png", height: image-height)
    ],

    [#mini-caption[実カメラ映像]],
    [],
    [#mini-caption[姿勢推定結果]],
    [],
    [#mini-caption[VRChat 反映結果]],
  )
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

#let main_py_flow = (
  "flowchart TD\n"
    + "  subgraph input[入力]\n"
    + "    cam[Webカメラ映像]\n"
    + "  end\n"
    + "  subgraph estimate[姿勢推定]\n"
    + "    metrabs[MeTRAbsで姿勢推定]\n"
    + "    pose3d[3次元の関節座標]\n"
    + "    select[腰と両足の座標を抽出]\n"
    + "  end\n"
    + "  subgraph output[VR送信]\n"
    + "    convert[VRChat用の座標系に変換]\n"
    + "    osc[OSCでトラッカー位置を送信]\n"
    + "    avatar[アバター動作に反映]\n"
    + "  end\n"
    + "  cam --> metrabs\n"
    + "  metrabs --> pose3d\n"
    + "  pose3d --> select\n"
    + "  select --> convert\n"
    + "  convert --> osc\n"
    + "  osc --> avatar\n"
    + "  avatar --> cam\n"
)

#let main-flow-diagram(height: 200mm) = image(
  bytes(
    mermaid-svg(
      main_py_flow,
      layout: (
        node_spacing: 42,
      ),
    ),
  ),
  format: "svg",
  height: height,
)

#block(inset: 4mm)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 10mm,
    align: (left, top),
    [
      #text(
        size: 60pt,
        weight: "bold",
      )[単眼カメラを用いたVR向け仮想トラッカーの制作]
      #v(3.5mm)
      #text(size: 28pt)[著者: 野田蒼馬]
      #linebreak()
      #text(size: 22pt, fill: rgb("#555555"))[N高等学校]
    ],
    [
      #qr-panel("github.com/akazdayo/post-2603")
    ],
  )

  #v(8mm)
  #rule()
  #v(8mm)

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 10mm,
    align: (left, top),
    [
      #section(
        [結論],
        [
          本研究では、一般的なWebカメラだけでも、VRChatにおける腰・脚の位置変化をアバターへ反映できることを確認した。単眼映像から推定した3次元姿勢をトラッキング信号へ変換することで、フルトラッキングらしい基本動作を再現できた。
          #parbreak()
          一方で、回転情報の不足と処理遅延が残り、物理トラッカーの完全な代替には至らなかった。以上より、Webカメラのみを用いる手法は低コストな補助手法として有望だが、実用化には低遅延化と姿勢表現の改善が必要である。
        ],
      )

      #v(7mm)

      #section(
        [背景],
        [
          VR向けのFBT（Full Body Tracking, フルトラッキング）は、腰や足に物理トラッカーを装着する方式が主流である。しかし、高い安定性と引き換えに、機器費用や装着の手間といった導入負担が大きい。
          #parbreak()
          一方で、Webカメラの性能向上と単眼姿勢推定技術の発展により、映像から身体位置を推定すること自体は身近になってきた。
          #parbreak()
          そこで本研究では、一般的なWebカメラだけでVRChatにおけるフルトラッキング相当の体験がどこまで実現できるかを検証した。
        ],
      )

      #v(7mm)

      #section(
        [目的],
        [
          一般的なWebカメラで推定した3次元姿勢をVRChatで扱えるトラッキング信号へ変換し、低コストな身体トラッキング手法として成立するかを検証した。
        ],
      )

      #v(7mm)

      #section(
        [手法],
        [
          単眼Webカメラ映像に3次元人体姿勢推定モデル #link("https://github.com/isarandi/metrabs")[MeTRAbs] を適用し、関節位置を三次元座標として推定した。推定結果から腰と両足の情報を抽出し、VRChat向けのトラッキング信号へ変換した。
          #parbreak()
          整形後のデータをVRChat OSCを通じて各部位のトラッキングデータとして送信した。処理全体は「映像取得」「3D姿勢推定」「座標系補正」「VR向け送信」からなるリアルタイムパイプラインとして構成した。
          #v(2.5mm)
          #grid(
            columns: (0.42fr, 0.58fr),
            column-gutter: 4mm,
            align: (left, top),
            [
              #info-card(
                [実験条件],
                [
                  #spec-item([OS], [NixOS 25.11 (x86_64)])
                  //#v(-1.1mm)
                  #spec-item([GPU], [NVIDIA GeForce RTX 5070 Ti])
                  //#v(-1.1mm)
                  #spec-item([カメラ], [Microsoft LifeCam HD-3000])
                  //#v(-1.1mm)
                  #spec-item([入力映像], [640 × 480, 30 fps])
                  //#v(-1.1mm)
                  #spec-item([推定モデル], [PyTorch 版 MeTRAbs])
                  //#v(-1.1mm)
                  #spec-item([入力解像度], [384 × 384])
                ],
              )
            ],
            [
              #align(center)[
                #main-flow-diagram(height: 200mm)
              ]
              #v(1.2mm)
              #mini-caption[
                動作フロー図
              ]
            ],
          )
          #v(3mm)
          #demo-flow()
          #v(1.2mm)
          #mini-caption[
            カメラ映像からVRまでの大まかな概要
          ]
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [比較],
        [
          物理トラッカー方式は、専用センサによって安定した位置情報と回転情報を高精度に取得できる。その一方で、機器価格や装着の煩雑さが導入障壁になる。
          #parbreak()
          本手法は一般的なWebカメラだけで動作するため、低コストかつ導入が容易である。ただし、遮蔽や処理遅延の影響を受けやすく、関節の回転情報を直接得られない。
          #v(3mm)
          #grid(
            columns: (34mm, 1fr, 1fr),
            column-gutter: 1mm,
            row-gutter: 1mm,
            [#compare-head[項目]],
            [#compare-head[物理トラッカー]],
            [#compare-head[本手法]],

            [#compare-label[導入コスト]],
            [#compare-cell[高い]],
            [#compare-cell([低い], fill: light)],

            [#compare-label[装着・準備]],
            [#compare-cell[腰や脚に機器を装着]],
            [#compare-cell([カメラ設置のみ], fill: light)],

            [#compare-label[位置取得]],
            [#compare-cell[高精度で安定]],
            [#compare-cell([大まかな位置は追従], fill: light)],

            [#compare-label[回転取得]],
            [#compare-cell[可能]],
            [#compare-cell([不可], fill: light)],

            [#compare-label[遮蔽耐性]],
            [#compare-cell[高い]],
            [#compare-cell([低い], fill: light)],

            [#compare-label[遅延]],
            [#compare-cell[小さい]],
            [#compare-cell([負荷増加で大きくなる], fill: light)],
          )
        ],
      )
    ],
    [
      #section(
        [結果],
        [
          実験の結果、関節位置の推定精度は比較的良好であり、身体の大まかな動きや重心移動をVR上のアバターに反映できた。特に、腰や脚の位置変化はフルトラッキングらしい挙動として再現できた。
          #parbreak()
          一方で、関節の回転情報は取得できず、推定から送信までの過程でも無視できない遅延が生じた。推論時間の平均はアイドル時 51.17 ms、ゲーム実行時 85.18 ms であり、負荷の増加に伴って追従性が低下した。
          #parbreak()
          また、既存のVR機器が出力するトラッキングデータとの整合には追加の工夫が必要であることが分かった。
          #v(3mm)
          #image(
            "assets/inference_center_n500_overlay_elapsed_avg.png",
            width: 100%,
          )
          #v(1.5mm)
          #mini-caption[
            推論時間の比較。ゲーム実行時はアイドル時より平均遅延が増加し、追従性が低下した。
          ]
        ],
      )

      #v(7mm)

      #section(
        [失敗例],
        [
          回転軸を取得できないため、腰の回転が発生した際にトラッキングが極端に破綻する現象が発生した。
          #v(3mm)
          #grid(
            columns: (1fr, 1fr),
            column-gutter: 3mm,
            align: (center, top),
            [
              #flow-image("assets/failed_real.png", height: 96mm)
              #v(1.2mm)
              #mini-caption[実際の姿勢]
            ],
            [
              #flow-image("assets/failed_vrchat.png", height: 96mm)
              #v(1.2mm)
              #mini-caption[VRChat での反映]
            ],
          )
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [考察],
        [
          本手法は物理トラッカーの完全な代替には至っていないものの、低コストに身体位置を推定し、VR向け入力として利用できる可能性を示した。遅延を除けば十分に実用に近いだろう。
          #parbreak()
          特に、FBTの導入コストを抑えたい場合や、簡易的に身体動作をアバターへ反映したい場合には、有効な選択肢になりうる。一方で、安定性や精密な姿勢再現が求められる用途では、物理トラッカーとの差が依然として大きいことも明らかになった。
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [今後の課題・展望],
        [
          今後の課題として、まず推論処理の低遅延化が必要である。ゲーム実行時には追従性が低下したため、処理負荷の軽減や推定パイプラインの最適化が重要となる。
          #parbreak()
          また、単眼姿勢推定では関節の回転情報を直接得にくいため、回転の補完手法や推定精度の改善が求められる。さらに、既存のVRシステムや他方式のトラッカーと自然に連携できるようにすることで、単眼カメラベースの仮想トラッカーをより現実的な選択肢へ発展させられる可能性がある。
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [参考文献],
        [
          #reference-item("[1]", [
            isarandi, "metrabs," GitHub Repository.
            #h(1.5mm)
            #link(
              "https://github.com/isarandi/metrabs",
            )[github.com/isarandi/metrabs]
          ])
          #v(1.2mm)
          #reference-item("[2]", [
            I. Sarandi et al., "MeTRAbs: Metric-Scale Truncation-Robust Heatmaps for Absolute 3D Human Pose Estimation," arXiv:2007.07227, 2020.
            #h(1.5mm)
            #link("https://arxiv.org/abs/2007.07227")[arXiv]
          ])
          #v(1.2mm)
          #reference-item("[3]", [
            VRChat, "OSC Trackers."
            #h(1.5mm)
            #link(
              "https://docs.vrchat.com/docs/osc-trackers",
            )[docs.vrchat.com/docs/osc-trackers]
          ])
          #v(1.2mm)
        ],
      )
    ],
  )
]
