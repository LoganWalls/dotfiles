# Returns a flattened AST for `pipeline` with an index column
def flat-ast [pipeline: string] {
    ast $pipeline --flatten | enumerate | flatten
}

# Returns the index of the (flattened) AST token containing the character at
# index `char_index` in the AST's source code
def char-to-token-index [ast: table, char_index: int] {
    # Clip the position to make sure that it is in bounds
    let char_index = (
      [0 $char_index]
        | math max 
        | [$in ($ast | get span.end | math max)] 
        | math min
    )

    # Find the index of the token that contains the character at `position`
    let token_index = (
      $ast
      | where ($it.span.start <= $char_index) and ($char_index <= $it.span.end)
    )

    if ($token_index | is-empty) {
      null
    } else {
      $token_index
        | first
        | get "index"
    }
}

# Returns the name of the command closest to `position` in `pipeline`
export def command-at-position [pipeline: string, position: int] {
    let ast = (flat-ast $pipeline)
    if ($ast | is-empty) {
      return null
    }

    # Get the pipe segment that contains the token
    let cursor_token = (char-to-token-index $ast $position)
    let segment = (
      $ast
      | where "index" <= $cursor_token
      | sort-by index -r
      | take until {|row| $row.shape in ["shape_pipe" "shape_closure"]}
      | sort-by index
    )

    # The command name is the first internal or external call in the segment
    $segment
      | where shape in ["shape_internalcall" "shape_external"]
      | first
      | get -o content
}

# Returns the name of the command closest to the cursor in the current buffer
export def current-command [] {
    command-at-position (commandline) (commandline get-cursor)
}

# Splits the long and short versions of each flag into separate entries
# and formats them nicely for fuzzy finding
def format-flags []: [table -> table] {
  let flags = $in | rename --block {str downcase}
  $flags 
    | default "" type usage
    | select -o "shorthand" "type" "usage" 
    | compact shorthand
    | update shorthand {|it| $"-($it.shorthand)" }
    | rename --column {shorthand: name} 
    | append (
      $flags 
        | select -o "longhand" "type" "usage" 
        | compact longhand
        | update longhand {|it| $"--($it.longhand)" }
        | rename --column {longhand: name}
    )
}

# TODO: finish this; should unify names between this and carapace so both work with format-flags
export def builtin-command-flags [name: string] {
  let info = (scope commands | where name == $name)
  if ($info | is-empty) {
    return ""
  }
  $info
    | first 
    | get signatures
    | values 
    | reduce { |it, acc | $acc | append $it } 
    | where parameter_type == switch 
    | uniq
}

export def fuzzy-complete-flag [command_name?: string] {
  # TODO: get flag completions for builtins
  # can also try to parse --help as a last resort for things that aren't in carapace
  let command = if ($command_name | is-not-empty) { $command_name } else { $in }
  let alias_info = (scope aliases | where name == $command)
  let command = if ($alias_info | is-not-empty) { 
    let alias_script = (
      $alias_info 
        | first 
        | get expansion 
        | ast $in --flatten 
        | first 
        | get content
    )
    command-at-position $alias_script (($alias_script | str length) - 1)
  } else {
    $command
  }
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
    let flag_takes_arguments = false # TODO: infer the real value by getting the info for $command
    match $prev_token_shape { 
      "shape_internalcall" | "shape_external" | "shape_flag" => {
        if $flag_takes_arguments {
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
