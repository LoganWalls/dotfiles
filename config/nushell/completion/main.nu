use candidates.nu 
use context.nu

def column-width [candidates: table, column: cell-path, --padding: int = 2]: nothing -> int {
    (
      $candidates 
        | get $column 
        | each {str length} 
        | math max
    ) + $padding
}

export def fuzzy-complete-dwim [context: record]: nothing -> string {
  let candidates = (candidates for-context $context)
  if ($candidates | is-empty) {
    return ""
  }
  let name_width = (column-width $candidates name)
  $candidates 
    | (sk 
      --multi
      --prompt "  "
      --height "50%"
      --format {
        $"($in.name | fill -w $name_width)($in.description)"
      })
    | default [{ name: "" }]
    | get name
    | str join " "
}
