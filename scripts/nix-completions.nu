# Source this file in Nushell to use Nix's own completion results.
let previous_completer = $env.config.completions.external.completer
$env.config.completions.external.completer = {|spans|
  if ($spans | first) == "nix" {
    let result = with-env { NIX_GET_COMPLETIONS: (($spans | length) - 1 | into string) } {
      ^nix ...($spans | skip 1) | complete
    }
    let output = ($result.stdout | lines)
    if $result.exit_code == 0 and ($output | first) != "filenames" {
      $output | skip 1 | each {|line| $line | split row (char tab) | first }
    } else if $previous_completer != null {
      do $previous_completer $spans
    } else {
      null
    }
  } else if $previous_completer != null {
    do $previous_completer $spans
  } else {
    null
  }
}
