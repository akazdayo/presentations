# Repository Guidelines

## Project Structure & Module Organization

This repository is a monorepo of presentation sources organized as `YEAR/<presentation-name>/`. Each presentation declares catalog metadata in `presentation.json` and may contain `slides/` for Slidev, top-level `slides.md` for Marp, `poster/` for Typst, plus local `assets/`, components, snippets, or demos. Reusable themes, components, logos, and diagrams belong in `shared/`; starting points for new work live in `templates/`. Repository automation is in `scripts/`, with catalog logic and tests under `scripts/lib/`. Generated output goes to `_site/` or presentation-specific `dist/` directories and must not be committed.

## Build, Test, and Development Commands

Enter the reproducible toolchain with `nix develop`, then use:

- `just list` — show all auto-discovered presentations.
- `just dev nix-journey` — run a Slidev or Marp deck locally.
- `just build <name>` — build one catalog entry, including Typst posters.
- `just build-site` — build every web/PDF artifact and the Pages index.
- `bun test scripts/lib/presentations.test.ts` — run catalog unit tests.
- `just check` — run flake checks, formatting validation, hooks, and Typst builds.
- `just format` — apply treefmt formatting across supported file types.

For an individual JavaScript deck, install dependencies in its source directory with `bun install --frozen-lockfile`.

## Coding Style & Naming Conventions

Use LF line endings and preserve Markdown prose wrapping. Let treefmt enforce Alejandra for Nix, Prettier for Markdown/JSON/YAML/TypeScript/Vue, typstyle for Typst, shfmt for shell, `terraform fmt`, and gofmt. Follow existing two-space indentation in TypeScript, JSON, and Vue. Use lowercase kebab-case for presentation directories and catalog names (for example, `nix-cache-05-27`); use descriptive PascalCase names for Vue components. Keep format-specific configuration beside the presentation and move genuinely reusable material into `shared/`.

## Testing Guidelines

Tests use Bun's `bun:test` API and follow the `*.test.ts` naming pattern. Add or update tests whenever catalog discovery, routes, metadata defaults, build matrices, or artifact paths change. Before submitting, run the focused Bun test and `just check`; use `just build <name>` for content or configuration changes affecting a specific presentation.

## Commit & Pull Request Guidelines

Recent history uses short, outcome-focused subjects, often in Japanese, with optional Conventional Commit prefixes such as `fix:`, `refactor:`, and `ci:`. Keep each commit scoped and use an imperative summary. Pull requests should explain the affected presentation or shared tooling, list verification commands, and link relevant issues. Include screenshots or exported pages for visible slide/poster changes, and do not include generated PDFs, `_site/`, `dist/`, or dependency directories.
