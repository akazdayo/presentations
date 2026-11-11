{
  description = "Presentation monorepo for Slidev, Marp, and Typst";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

        slidevPrettierPlugin = pkgs.callPackage ./tools/slidev-prettier {};

        treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs = {
            alejandra.enable = true;
            gofmt.enable = true;
            prettier = {
              enable = true;
              settings = {
                endOfLine = "lf";
                proseWrap = "preserve";
                plugins = ["${slidevPrettierPlugin}/node_modules/prettier-plugin-slidev/dist/index.js"];
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

        src = ./.;

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

        posterEntries =
          lib.concatMap (year: let
            yearPath = ./. + "/${year}";
            entries = builtins.readDir yearPath;
          in
            lib.concatMap (name: let
              directory = yearPath + "/${name}";
            in
              lib.optional (
                entries.${name}
                == "directory"
                && builtins.pathExists (directory + "/poster/main.typ")
                && !(builtins.pathExists (directory + "/package.json"))
                && !(builtins.pathExists (directory + "/slides/package.json"))
              ) {
                inherit name;
                value = "${year}/${name}/poster/main.typ";
              }) (builtins.attrNames entries))
          (builtins.filter (name:
            (builtins.readDir ./.).${name}
            == "directory"
            && builtins.match "[0-9]{4}" name != null)
          (builtins.attrNames (builtins.readDir ./.)));

        posterSources =
          if builtins.length (lib.unique (map (entry: entry.name) posterEntries)) != builtins.length posterEntries
          then throw "Typst poster names must be unique across years"
          else builtins.listToAttrs posterEntries;

        posterPackages =
          lib.mapAttrs (
            _: typstSource:
              typixLib.buildTypstProject (commonTypstArgs // {inherit src typstSource unstable_typstPackages;})
          )
          posterSources;
        posterApps =
          lib.mapAttrs' (name: typstSource: {
            name = "build-${name}";
            value = flake-utils.lib.mkApp {
              drv = typixLib.buildTypstProjectLocal (commonTypstArgs
                // {
                  inherit src typstSource unstable_typstPackages;
                  typstOutput = "${builtins.dirOf typstSource}/poster.pdf";
                });
            };
          })
          posterSources;

        watchApps =
          lib.mapAttrs' (name: typstSource: {
            name = "watch-${name}";
            value = flake-utils.lib.mkApp {
              drv = typixLib.watchTypstProject (commonTypstArgs
                // {
                  inherit typstSource;
                  typstOutput = "${builtins.dirOf typstSource}/poster.pdf";
                });
            };
          })
          posterSources;
      in {
        apps = posterApps // watchApps;

        packages =
          posterPackages
          // {
            default = posterPackages.post-2603;
          };

        checks =
          lib.mapAttrs' (name: value: {
            name = "poster-${name}";
            inherit value;
          })
          posterPackages
          // {formatting = treefmtEval.config.build.check ./.;};

        formatter = treefmtEval.config.build.wrapper;

        devShells.default = typixLib.devShell {
          inherit (commonTypstArgs) fontPaths virtualPaths;
          extraShellHook = ''
            if [[ $- == *i* ]]; then
              printf '\nNushell の Nix 補完を使うには、リポジトリルートで実行してください:\n  source scripts/nix-completions.nu\n\n' >&2
            fi
          '';
          packages = [
            treefmtEval.config.build.wrapper
            pkgs.bun
            pkgs.nodejs_24
            pkgs.noto-fonts-cjk-sans
            pkgs.noto-fonts-color-emoji
          ];
        };
      }
    );
}
