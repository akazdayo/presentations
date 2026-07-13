set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

# List every presentation from the TypeScript catalog.
list:
  @bun run scripts/presentation.ts list

# Start a presentation in development mode by its catalog name.
dev name:
  bun run scripts/presentation.ts dev "{{name}}"

# Build any presentation by its catalog name.
build name:
  bun run scripts/presentation.ts build "{{name}}"

# Build every web artifact and generate the GitHub Pages Markdown index.
build-site:
  bun run scripts/build-site.ts

# Check the Nix flake and build all Typst posters.
check:
  nix flake check path:.

# Format every supported source file through treefmt.
format:
  nix fmt
