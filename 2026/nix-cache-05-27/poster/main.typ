#import "@preview/zebra:0.1.0": qrcode
#import "@preview/mmdr:0.2.1": mermaid-svg
#import "../../../shared/components/typst/poster-helpers.typ": *

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

#let evidence-flow-diagram(height: 220mm) = image(
  bytes(
    mermaid-svg(
      "flowchart TD\n"
        + "  subgraph build[Nix ビルド]\n"
        + "    drv[導出記述子] --> build_exec[ビルド実行]\n"
        + "  end\n"
        + "  subgraph evidence[証拠収集]\n"
        + "    tee[TEE証明 TDX / SEV-SNP / Nitro]\n"
        + "    repro[再現性検証 独立ビルダ比較]\n"
        + "    rekor[透過性ログ Sigstore Rekor]\n"
        + "    slsa[SLSA証明書 in-toto メタデータ]\n"
        + "  end\n"
        + "  subgraph scoring[信頼スコア計算]\n"
        + "    aggregate[証拠統合] --> cluster[独立性クラスタ分析]\n"
        + "    cluster --> score[スコア算出]\n"
        + "  end\n"
        + "  build_exec --> tee\n"
        + "  build_exec --> repro\n"
        + "  build_exec --> rekor\n"
        + "  build_exec --> slsa\n"
        + "  tee --> aggregate\n"
        + "  repro --> aggregate\n"
        + "  rekor --> aggregate\n"
        + "  slsa --> aggregate\n",
      layout: (node_spacing: 42),
    ),
  ),
  format: "svg",
  height: height,
)

#let scoring-axes-diagram(height: 180mm) = image(
  bytes(
    mermaid-svg(
      "flowchart LR\n"
        + "  subgraph axes[スコア軸]\n"
        + "    C[一貫性 Consistency]\n"
        + "    I[独立性 Independence]\n"
        + "    T[透明性 Transparency]\n"
        + "  end\n"
        + "  subgraph evidence[証拠タイプ]\n"
        + "    D1[TEE Quote]\n"
        + "    D2[ビルドログ]\n"
        + "    D3[出力ハッシュ]\n"
        + "    D4[署名]\n"
        + "    D5[依存閉包]\n"
        + "  end\n"
        + "  D1 --> C\n"
        + "  D3 --> C\n"
        + "  D5 --> C\n"
        + "  D1 --> I\n"
        + "  D3 --> I\n"
        + "  D4 --> I\n"
        + "  D2 --> T\n"
        + "  D4 --> T\n"
        + "  D1 --> T\n",
      layout: (node_spacing: 42),
    ),
  ),
  format: "svg",
  height: height,
)

#let sybil-attack-diagram(height: 160mm) = image(
  bytes(
    mermaid-svg(
      "flowchart TD\n"
        + "  subgraph attack[Sybil攻撃の例]\n"
        + "    op1[1人の運営者] --> tee1[TEEインスタンス A]\n"
        + "    op1 --> tee2[TEEインスタンス B]\n"
        + "    op1 --> tee3[TEEインスタンス C]\n"
        + "  end\n"
        + "  subgraph mitigate[独立性クラスタによる緩和]\n"
        + "    op2[運営者 A] --> tee4[TEE]\n"
        + "    op3[運営者 B] --> tee5[TEE]\n"
        + "    op4[運営者 C] --> tee6[TEE]\n"
        + "  end\n"
        + "  attack -->|同一クラスタとして集約| mitigate\n",
      layout: (node_spacing: 42),
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
      )[TEEを活用したNixバイナリキャッシュの信頼スコアリング]
      #v(3.5mm)
      #text(size: 28pt)[著者: 野田蒼馬]
      #linebreak()
      #text(size: 22pt, fill: rgb("#555555"))[N高等学校]
    ],
    [
      #qr-panel("github.com/akazdayo/nix-cache-5-27")
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
          TEE（Trusted Execution Environment）単独では、Nixバイナリキャッシュの信頼根拠として不十分である。Sybil攻撃により同一運営者が複数のTEEインスタンスを生成でき、TEE自体の脆弱性（SGAxe, Plundervolt等）も確認されている。
          #parbreak()
          しかし、TEE証明を複数の独立的な証拠タイプと組み合わせることで、信頼を「信頼する／しない」の二値から定量的なスコアへ移行できる。本提案では、独立性クラスタに基づく重み付け手法により、Nixバイナリキャッシュの分散化と信頼性向上を両立する。
        ],
      )

      #v(7mm)

      #section(
        [背景],
        [
          Nixのバイナリキャッシュは、信頼済み署名鍵によって成果物の信頼性を担保する。しかし、ユーザはキャッシュされた成果物が指定された入力から実際にビルドされたことを、自ら再ビルドしなければ検証できない。この制約により、nixpkgsのような大規模な権威的リポジトリへの利用が集中する構造的課題が生じている。
          #parbreak()
          バイナリ信頼（信頼／非信頼）は粗すぎる粒度であり、異なる証拠レベルを統合する枠組みが求められている。
        ],
      )

      #v(7mm)

      #section(
        [目的],
        [
          Nixバイナリキャッシュ向けの多証拠信頼スコアリングフレームワークを提案する。具体的には、(1) バイナリ信頼から定量的信頼スコアへの移行、(2) 証拠の独立性クラスタを重視する重み付け手法の設計、(3) TEE証明・再現性検証・透過性ログ・SLSA証明書・閾値署名の5種の証拠を統合するスコア計算方式の定義を行う。
        ],
      )

      #v(7mm)

      #section(
        [手法],
        [
          5種の証拠タイプを収集し、それらを統合して信頼スコアを算出する。TEE証明はハードウェアによる証明を提供するが、単独ではSybil攻撃に脆弱である。したがって、複数の独立的な証拠を組み合わせ、独立性クラスタごとに重み付けを行う。
          #parbreak()
          処理全体は「ビルド実行」「証拠収集」「スコア算出」からなるパイプラインとして構成した。
          #v(2.5mm)
          #grid(
            columns: (0.42fr, 0.58fr),
            column-gutter: 4mm,
            align: (left, top),
            [
              #info-card(
                [証拠タイプ],
                [
                  #spec-item(
                    [TEE証明],
                    [Intel TDX, AMD SEV-SNP, AWS Nitro Enclaves],
                  )
                  #spec-item([再現性検証], [複数独立ビルダの出力一致検証])
                  #spec-item([透過性ログ], [Sigstore Rekor, Sigsum, CHAINIAC])
                  #spec-item([SLSA証明書], [in-toto メタデータ, SLSA Lv3+])
                  #spec-item([閾値署名], [k-of-n マルチパーティ承認])
                ],
              )
            ],
            [
              #align(center)[
                #evidence-flow-diagram(height: 220mm)
              ]
              #v(1.2mm)
              #mini-caption[
                証拠収集から信頼スコア算出までのフロー
              ]
            ],
          )
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [比較],
        [
          各アプローチの特徴を比較する。提案手法は、複数の証拠タイプを統合し、独立性クラスタによる重み付けを行うことで、いずれの単一アプローチよりも高い信頼性を実現する。
          #v(3mm)
          #grid(
            columns: (30mm, 1fr, 1fr, 1fr, 1fr),
            column-gutter: 1mm,
            row-gutter: 1mm,
            [#compare-head[項目]],
            [#compare-head[再現性ビルド]],
            [#compare-head[透明性ログ]],
            [#compare-head[TEEのみ]],
            [#compare-head[提案手法]],

            [#compare-label[証拠型]],
            [#compare-cell[出力一致, fill: light]],
            [#compare-cell[ログ記録]],
            [#compare-cell[ハードウェア証明]],
            [#compare-cell([統合], fill: light)],

            [#compare-label[独立性]],
            [#compare-cell([高い], fill: light)],
            [#compare-cell[中程度]],
            [#compare-cell[低い（Sybil）]],
            [#compare-cell([高い], fill: light)],

            [#compare-label[検証可能性]],
            [#compare-cell[ビルド再実行]],
            [#compare-cell[ログ照合]],
            [#compare-cell[Quote検証]],
            [#compare-cell([多軸検証], fill: light)],

            [#compare-label[実装難度]],
            [#compare-cell[低い]],
            [#compare-cell[中程度]],
            [#compare-cell[高い]],
            [#compare-cell[中程度]],

            [#compare-label[Sybil耐性]],
            [#compare-cell([高い], fill: light)],
            [#compare-cell[中程度]],
            [#compare-cell[低い]],
            [#compare-cell([高い], fill: light)],
          )
        ],
      )
    ],
    [
      #section(
        [信頼スコア設計],
        [
          信頼スコアは3つの評価軸に基づいて計算される。一貫性（Consistency）は同一入力から同一出力が得られる度合い、独立性（Independence）は証拠ソース間の運営的・技術的独立性、透過性（Transparency）は外部検証可能性の度合いを評価する。各軸のスコアを独立性クラスタごとに集約し、生の証拠数よりも独立性を重視する重み付けを適用する。
          #v(3mm)
          #align(center)[
            #scoring-axes-diagram(height: 180mm)
          ]
          #v(1.2mm)
          #mini-caption[
            スコア軸と証拠タイプのマッピング
          ]
          #v(3mm)
          #info-card(
            [証拠レコード構造],
            [
              #spec-item([導出ハッシュ], [derivation hash])
              #spec-item([ソースリビジョン], [source revision])
              #spec-item([依存閉包ハッシュ], [dependency closure hash])
              #spec-item([出力ハッシュ], [output hash])
              #spec-item([ビルダ証明], [builder provenance])
              #spec-item([ビルドログ], [build log])
              #spec-item([TEE Quote], [TEE attestation quote])
            ],
          )
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [TEEの限界と脅威],
        [
          TEEはハードウェアレベルの隔離を提供するが、信頼の唯一の根拠としては不十分である。Sybil攻撃により、単一の運営者が多数のTEEインスタンスを生成し、独立した証拠源であるかのように偽装できる。また、TEEプラットフォーム自体に既知の脆弱性が存在する。
          #v(3mm)
          #align(center)[
            #sybil-attack-diagram(height: 160mm)
          ]
          #v(1.2mm)
          #mini-caption[
            Sybil攻撃と独立性クラスタによる緩和
          ]
          #v(3mm)
          #info-card(
            [既知のTEE脆弱性],
            [
              #spec-item([SGAxe], [SGX側チャネル攻撃、Enclaveメモリ漏洩])
              #spec-item([Plundervolt], [電圧操作によるSGX侵害])
              #spec-item([Foreshadow], [L1ターミナルフォールトによる読み出し])
              #spec-item([TEE.fail], [TEEプラットフォーム包括的脆弱性分析])
            ],
          )
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [考察],
        [
          独立性クラスタによる重み付けは、生の証拠数よりも信頼性の高い評価を提供する。同一運営者が複数のTEEインスタンスを起動しても、それらは1つのクラスタとして集約されるため、Sybil攻撃に対してロバストである。
          #parbreak()
          Nixpkgsの再現性は2023年時点で91%のビットレベル再現性と99.8%の再ビルド可能性を達成しており、再現性検証を証拠として活用する基盤は整っている。しかし、現在の構造的課題として、大規模リポジトリへの信頼集中が進んでおり、信頼スコアによる分散化の促進が期待される。
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [今後の課題・展望],
        [
          今後の課題として、まず信頼スコアリングのプロトタイプ実装を開発し、Nixのsubstitutorプロトコルへの統合を行う必要がある。また、新しい証拠が追加された際の動的スコア更新手法の設計も求められる。
          #parbreak()
          さらに、ビルダの独立性をどのように評価・検証するかの手法論的整理が必要である。TEE技術の進化（Intel TDX第2世代、AMD SEV-SNP v3等）に伴う信頼モデルの変化にも継続的に対応していく必要がある。
        ],
        level: 2,
      )

      #v(7mm)

      #section(
        [参考文献],
        [
          #reference-item("[1]", [
            NixOS, "Nix Manual — Trusted Binary Caches."
            #h(1.5mm)
            #link(
              "https://nixos.org/manual/nix/stable",
            )[nixos.org/manual/nix/stable]
          ])
          #v(1.2mm)
          #reference-item("[2]", [
            SLSA, "Supply-chain Levels for Software Artifacts."
            #h(1.5mm)
            #link("https://slsa.dev")[slsa.dev]
          ])
          #v(1.2mm)
          #reference-item("[3]", [
            in-toto, "A framework to secure software supply chains."
            #h(1.5mm)
            #link("https://in-toto.io")[in-toto.io]
          ])
          #v(1.2mm)
          #reference-item("[4]", [
            Sigstore, "Rekor Transparency Log."
            #h(1.5mm)
            #link("https://sigstore.dev")[sigstore.dev]
          ])
          #v(1.2mm)
          #reference-item("[5]", [
            Lau et al., "CHAINIAC: Proactive Software Supply Chain Integrity."
            #h(1.5mm)
            IEEE Symposium on Security and Privacy, 2019.
          ])
          #v(1.2mm)
          #reference-item("[6]", [
            Reproducible Builds, "Nixpkgs Reproducibility Status."
            #h(1.5mm)
            #link("https://r13y.com")[r13y.com]
          ])
          #v(1.2mm)
          #reference-item("[7]", [
            Moghimi et al., "SGAxe / Plundervolt / Foreshadow — TEE Vulnerability Papers."
            #h(1.5mm)
            #link("https://tee.fail")[tee.fail]
          ])
          #v(1.2mm)
          #reference-item("[8]", [
            Coppieters et al., "Attestable Builds: Reproducible Builds + TEE."
            #h(1.5mm)
            ACM CCS, 2024.
          ])
          #v(1.2mm)
        ],
      )
    ],
  )
]
