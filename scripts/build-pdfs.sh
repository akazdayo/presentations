#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_DIR="${ROOT}/_site"
FLAKE_REF="${FLAKE_REF:-path:${ROOT}}"

rm -rf "${SITE_DIR}"
mkdir -p "${SITE_DIR}"

copy_typst_pdf() {
  local name="$1"
  local destination="$2"
  local output pdf

  output="$(nix build "${FLAKE_REF}#${name}" --no-link --print-out-paths)"
  if [[ -f ${output} ]]; then
    pdf="${output}"
  else
    pdf="$(find "${output}" -type f -name '*.pdf' -print -quit)"
  fi

  if [[ -z ${pdf} ]]; then
    echo "No PDF produced for Typst target: ${name}" >&2
    return 1
  fi

  mkdir -p "$(dirname "${SITE_DIR}/${destination}")"
  cp "${pdf}" "${SITE_DIR}/${destination}"
}

build_slidev_pdf() {
  local source="$1"
  local destination="$2"
  local chromium
  chromium="$(command -v chromium)"

  mkdir -p "$(dirname "${SITE_DIR}/${destination}")"
  (
    cd "${ROOT}/${source}"
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 bun install --frozen-lockfile --ignore-scripts
    bun run export -- \
      --output "${SITE_DIR}/${destination}" \
      --executable-path "${chromium}" \
      --timeout 120000 \
      --wait 1000
  )
}

build_marp_pdf() {
  local chromium
  chromium="$(command -v chromium)"
  mkdir -p "${SITE_DIR}/2026/nix-lt"
  (
    cd "${ROOT}/2026/nix-lt"
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 bun install --frozen-lockfile --ignore-scripts
    bunx marp slides.md \
      --pdf \
      --allow-local-files \
      --browser-path "${chromium}" \
      --output "${SITE_DIR}/2026/nix-lt/slides.pdf"
  )
}

echo "Building Typst posters"
copy_typst_pdf post-2603 2026/post-2603/poster.pdf
copy_typst_pdf nix-cache-05-27 2026/nix-cache-05-27/poster.pdf
copy_typst_pdf sechack-2nd-event 2026/sechack-2nd-event/poster.pdf

echo "Building Marp deck"
build_marp_pdf

echo "Building Slidev decks"
build_slidev_pdf 2025/nostr-one-year/slides 2025/nostr-one-year/slides.pdf
build_slidev_pdf 2025/slidev-mobile-claude/slides 2025/slidev-mobile-claude/slides.pdf
build_slidev_pdf 2026/conversation-thermometer/slides 2026/conversation-thermometer/slides.pdf
build_slidev_pdf 2026/nix-journey/slides 2026/nix-journey/slides.pdf
build_slidev_pdf 2026/nix-minecraft/slides 2026/nix-minecraft/slides.pdf
build_slidev_pdf 2026/nix-tee/slides 2026/nix-tee/slides.pdf
build_slidev_pdf 2026/sechack-1st-event 2026/sechack-1st-event/slides.pdf

echo "Generating GitHub Pages Markdown index"
bun run "${ROOT}/scripts/build-site.ts"
