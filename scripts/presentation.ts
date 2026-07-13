import {
  buildPresentation,
  devPresentation,
  findPresentation,
  presentations,
} from "./lib/presentations";

function usage(): never {
  throw new Error(
    "Usage: bun run scripts/presentation.ts <list|dev|build> [name]",
  );
}

const [command, name, ...extraArguments] = Bun.argv.slice(2);

if (extraArguments.length > 0) usage();

switch (command) {
  case "list":
    if (name) usage();
    for (const presentation of presentations) {
      console.log(
        [
          presentation.name.padEnd(26),
          presentation.date.padEnd(27),
          presentation.kind,
        ].join(" "),
      );
    }
    break;
  case "dev":
    if (!name) usage();
    devPresentation(findPresentation(name));
    break;
  case "build":
    if (!name) usage();
    buildPresentation(findPresentation(name));
    break;
  default:
    usage();
}
