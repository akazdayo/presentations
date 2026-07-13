set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

# List every migrated presentation.
list:
  @printf '%s\n' \
    'nostr-one-year          2025-12-19  Slidev' \
    'slidev-mobile-claude    2025-12-20  Slidev' \
    'nix-lt                  2026-02-13  Marp' \
    'post-2603               2026-03     Typst' \
    'nix-journey             2026-03-11  Slidev' \
    'nix-cache-05-27         2026-05-27  Typst' \
    'conversation-thermometer 2026-05-30 Slidev' \
    'nix-tee                 2026-06-05  Slidev' \
    'nix-minecraft           2026-06-06  Slidev' \
    'sechack-1st-event       2026 summer Slidev' \
    'sechack-2nd-event       2026 summer Typst'

# Start a Slidev deck by its catalog name.
dev name:
  path="$$(case "{{name}}" in \
    nostr-one-year) echo 2025/nostr-one-year/slides ;; \
    slidev-mobile-claude) echo 2025/slidev-mobile-claude/slides ;; \
    conversation-thermometer) echo 2026/conversation-thermometer/slides ;; \
    nix-journey) echo 2026/nix-journey/slides ;; \
    nix-minecraft) echo 2026/nix-minecraft/slides ;; \
    nix-tee) echo 2026/nix-tee/slides ;; \
    sechack-1st-event) echo 2026/sechack-1st-event ;; \
    *) echo 'unknown Slidev deck: {{name}}' >&2; exit 2 ;; \
  esac)"; cd "$${path}"; bun run dev

# Build a Slidev deck by its catalog name.
build-slides name:
  path="$$(case "{{name}}" in \
    nostr-one-year) echo 2025/nostr-one-year/slides ;; \
    slidev-mobile-claude) echo 2025/slidev-mobile-claude/slides ;; \
    conversation-thermometer) echo 2026/conversation-thermometer/slides ;; \
    nix-journey) echo 2026/nix-journey/slides ;; \
    nix-minecraft) echo 2026/nix-minecraft/slides ;; \
    nix-tee) echo 2026/nix-tee/slides ;; \
    sechack-1st-event) echo 2026/sechack-1st-event ;; \
    *) echo 'unknown Slidev deck: {{name}}' >&2; exit 2 ;; \
  esac)"; cd "$${path}"; bun run build

# Preview the Marp deck.
dev-marp:
  cd 2026/nix-lt; bun run dev

# Export the Marp deck to PDF.
build-marp:
  cd 2026/nix-lt; bun run build

# Build one Typst poster: post-2603, nix-cache-05-27, or sechack-2nd-event.
build-poster name:
  nix build ".#{{name}}"

# Build every PDF and generate the GitHub Pages root site.
build-all-pdfs:
  ./scripts/build-pdfs.sh

# Check the Nix flake and build all Typst posters.
check:
  nix flake check path:.

# Format every supported source file through treefmt.
format:
  nix fmt
