{
  description = "Presentation monorepo for Slidev, Marp, and Typst";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Kept in the input set so the migrated lock file stays reproducible.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    markdown-nix.url = "github:akazdayo/markdown.nix";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    typix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        inherit (pkgs) lib;
        typixLib = typix.lib.${system};

        slidevPrettier = pkgs.buildNpmPackage {
          pname = "slidev-prettier";
          version = "1.0.0";
          src = ./tools/slidev-prettier;
          npmDepsHash = "sha256-u9wpcUqJ3DnWE9Jz5EMEO0fSVFjJ3qZup10rvTbgMmY=";
          dontNpmBuild = true;
          nativeBuildInputs = [pkgs.makeWrapper];
          meta.mainProgram = "prettier";
          installPhase = ''
            runHook preInstall

            mkdir -p "$out/lib/slidev-prettier" "$out/bin"
            cp -r node_modules "$out/lib/slidev-prettier/"
            makeWrapper ${pkgs.nodejs}/bin/node "$out/bin/prettier" \
              --add-flags "$out/lib/slidev-prettier/node_modules/prettier/bin/prettier.cjs" \
              --add-flags "--plugin=$out/lib/slidev-prettier/node_modules/prettier-plugin-slidev/dist/index.js"

            runHook postInstall
          '';
        };

        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs = {
            alejandra.enable = true;
            gofmt.enable = true;
            prettier = {
              enable = true;
              package = slidevPrettier;
              settings = {
                endOfLine = "lf";
                proseWrap = "preserve";
                overrides = [
                  {
                    files = [
                      "**/slides/slides.md"
                      "**/slides/pages/*.md"
                      "2026/sechack-1st-event/slides.md"
                      "2026/sechack-1st-event/pages/*.md"
                      "templates/slidev/slides.md"
                      "templates/slidev/pages/*.md"
                    ];
                    options.parser = "slidev";
                  }
                ];
              };
            };
            shfmt.enable = true;
            terraform = {
              enable = true;
              package = pkgs.terraform;
            };
            typstyle.enable = true;
          };

          settings.global.excludes = [
            "**/.terraform/**"
            "**/bun.lock"
            "**/node_modules/**"
            "**/dist/**"
            "**/_site/**"
          ];
        };

        checkSource = lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            lib.cleanSourceFilter path type
            && !builtins.elem (builtins.baseNameOf path) [
              ".direnv"
              ".git"
              ".pre-commit-config.yaml"
              ".slidev"
              ".terraform"
              "_site"
              "dist"
              "node_modules"
              "result"
            ];
        };

        typstSource = typixLib.cleanTypstSource ./.;
        typstAssetSource = lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            type
            == "directory"
            || (
              let
                sourcePath = toString path;
              in
                (lib.hasInfix "/poster/" sourcePath
                  || lib.hasInfix "/shared/" sourcePath)
                && builtins.any (suffix: lib.hasSuffix suffix sourcePath) [
                  ".csv"
                  ".gif"
                  ".jpeg"
                  ".jpg"
                  ".json"
                  ".png"
                  ".svg"
                  ".webp"
                  ".yaml"
                  ".yml"
                ]
            );
        };
        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [
            (lib.fileset.fromSource typstSource)
            (lib.fileset.fromSource typstAssetSource)
          ];
        };

        commonTypstArgs = {
          fontPaths = ["${pkgs.ipafont}/share/fonts"];
          typstOpts.root = ".";
          virtualPaths = [];
        };

        unstable_typstPackages = [
          {
            name = "zebra";
            version = "0.1.0";
            hash = "sha256-Z2rDhzO+MMVwHCQvOZClxmyzextcPvPR3zRw5PS2C7U=";
          }
          {
            name = "mmdr";
            version = "0.2.1";
            hash = "sha256-RQQsoqftwanuqN6GglxymDcO2dBcoIgSzqHvIjm1GfA=";
          }
        ];

        posterSources = {
          post-2603 = "2026/post-2603/poster/main.typ";
          nix-cache-05-27 = "2026/nix-cache-05-27/poster/main.typ";
          sechack-2nd-event = "2026/sechack-2nd-event/poster/main.typ";
        };

        posterPackages =
          lib.mapAttrs (
            _: typstSource:
              typixLib.buildTypstProject (
                commonTypstArgs
                // {inherit src typstSource unstable_typstPackages;}
              )
          )
          posterSources;

        posterBuildScripts =
          lib.mapAttrs (
            _: typstSource:
              typixLib.buildTypstProjectLocal (
                commonTypstArgs
                // {inherit src typstSource unstable_typstPackages;}
              )
          )
          posterSources;

        posterWatchScripts =
          lib.mapAttrs (
            name: typstSource:
              typixLib.watchTypstProject (
                commonTypstArgs
                // {
                  inherit typstSource;
                  scriptName = "typst-watch-${name}";
                }
              )
          )
          posterSources;

        preCommitCheck = inputs.git-hooks.lib.${system}.run {
          src = checkSource;
          hooks.treefmt = {
            enable = true;
            package = treefmtEval.config.build.wrapper;
          };
        };
      in {
        packages = posterPackages // {default = posterPackages.post-2603;};

        apps =
          lib.mapAttrs' (name: value: {
            name = "build-${name}";
            value = flake-utils.lib.mkApp {drv = value;};
          })
          posterBuildScripts
          // lib.mapAttrs' (name: value: {
            name = "watch-${name}";
            value = flake-utils.lib.mkApp {drv = value;};
          })
          posterWatchScripts;

        checks =
          lib.mapAttrs' (name: value: {
            name = "poster-${name}";
            inherit value;
          })
          posterPackages
          // {
            formatting = treefmtEval.config.build.check checkSource;
            pre-commit = preCommitCheck;
          };

        formatter = treefmtEval.config.build.wrapper;

        devShells.default = typixLib.devShell {
          inherit (commonTypstArgs) fontPaths virtualPaths;
          extraShellHook = preCommitCheck.shellHook;
          packages =
            preCommitCheck.enabledPackages
            ++ builtins.attrValues posterWatchScripts
            ++ [
              treefmtEval.config.build.wrapper
              pkgs.bun
              pkgs.go
              pkgs.just
              pkgs.marp-cli
              pkgs.nodejs_24
              pkgs.noto-fonts-cjk-sans
              pkgs.noto-fonts-color-emoji
              pkgs.terraform
            ];
        };
      }
    );
}
