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
        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [
            (lib.fileset.fromSource typstSource)
            ./2026
            ./shared
            ./templates
          ];
        };

        commonTypstArgs = {
          inherit src;
          fontPaths = ["${pkgs.ipafont}/share/fonts"];
          typstOpts.root = ".";
          virtualPaths = [];
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
        };

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
                // {inherit typstSource;}
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

        devShells.default = pkgs.mkShell {
          inherit (preCommitCheck) shellHook;
          packages =
            preCommitCheck.enabledPackages
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
              pkgs.typst
            ];
        };
      }
    );
}
