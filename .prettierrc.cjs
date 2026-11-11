module.exports = {
  endOfLine: "lf",
  proseWrap: "preserve",
  plugins: [
    require.resolve(
      "./tools/slidev-prettier/node_modules/prettier-plugin-slidev/dist/index.js",
    ),
  ],
  overrides: [
    { files: "*.md", options: { parser: "markdown" } },
    {
      files: [
        "**/slides/slides.md",
        "**/slides/pages/*.md",
        "2026/sechack-1st-event/slides.md",
        "2026/sechack-1st-event/pages/*.md",
        "templates/slidev/slides.md",
        "templates/slidev/pages/*.md",
      ],
      options: { parser: "slidev" },
    },
  ],
};
