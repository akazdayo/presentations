import {
  buildPresentation,
  devPresentation,
  findPresentation,
  presentations,
} from "./lib/presentations";

function usage(): never {
  throw new Error(
    "Usage: bun run scripts/presentation.ts <list [--json]|dev|build> [name]",
  );
}

const [command, argument, ...extraArguments] = Bun.argv.slice(2);

if (extraArguments.length > 0) usage();

switch (command) {
  case "list":
    if (argument === "--json") {
      console.log(JSON.stringify(presentations.map(({ name }) => name)));
      break;
    }
    if (argument) usage();
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
    if (!argument) usage();
    devPresentation(findPresentation(argument));
    break;
  case "build":
    if (!argument) usage();
    buildPresentation(findPresentation(argument));
    break;
  default:
    usage();
}
