export def fuzzy-complete-flag [command_name?: string] {
  # TODO: get flag completions for builtins
  # can also try to parse --help as a last resort for things that aren't in carapace
  let command = (if ($command_name | is-not-empty) { $command_name } else { $in } 
    | expand-alias
    | command-at-position $in (($in | str length) - 1)
  )
  if ($command | is-empty) {
    return ""
  }

  let carapace_data = (carapace $command export | from json)
  if ($carapace_data | is-empty) {
    return ""
  }

  let flags = (
    $carapace_data
    | get LocalFlags
    | format-flags
  )
  let padding = 2
  let flag_length = (
    $flags 
    | get name 
    | each {str length} 
    | math max
  ) + $padding
  let type_length = (
    $flags 
    | get type 
    | each {str length} 
    | math max
  ) + $padding

  $flags 
    | (sk 
      --multi
      --prompt "  "
      --height "30%"
      --format {
        $"($in.name | fill -w $flag_length)($in.type | fill -w $type_length)($in.usage)"
      })
    | default [{ name: "" }]
    | get name
    | str join " "
}


export def fuzzy-complete-dwim [] {
    let pipeline = (commandline)
    if ($pipeline | str trim | is-empty) {
      return "COMMAND"
    }

    let cursor = (commandline get-cursor) 
    let command = command-at-position $pipeline $cursor

    let prev_char_index = ([($cursor - 1) 0] | math max)
    let prev_char = ($pipeline | str substring $prev_char_index..$prev_char_index)
    if $prev_char == "-" {
      return "FLAG"
    } 

    let ast = (flat-ast $pipeline)
    let cursor_token_index = (char-to-token-index $ast $cursor)
    let prev_token_shape = if ($cursor_token_index == 0) {
      null
    } else {
      $ast | select ($cursor_token_index - 1) | get shape
    }
    let flag_takes_arguments = false # TODO: infer the real value by getting the info for $command, `parameter_type` named vs switch might differenatiate
    match $prev_token_shape { 
      "shape_internalcall" | "shape_external" | "shape_flag" => {
        if $flag_takes_arguments {
          # TODO: handle case where arg takes fixed set of values (builtin completion now handles this; can look at implementation)
          #  scope commands | where name == "table" | get signatures | first | values | first | where parameter_name == "theme" | first | get completion  
          "FLAG_ARG"
        } else {
          "SUBCOMMAND_OR_POSITIONAL"
        }
      }
      _ => {
        # TODO: `rg ^` has a `null` previous token because of the postition clipping we use
        $prev_token_shape
      }
    }
}
