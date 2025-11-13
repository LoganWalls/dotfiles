use candidates.nu

# Returns a flattened AST for `pipeline` with an index column
export def flat-ast [pipeline: string] {
    ast $pipeline --flatten | enumerate | flatten
}

# Returns the index of the (flattened) AST token containing the character at
# index `char_index` in the AST's source code
export def char-to-token-index [ast: table, char_index: int] {
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
export def command-at-position [pipeline: string, position: int]: nothing -> record {
    let ast = (flat-ast $pipeline)
    if ($ast | is-empty) {
      return null
    }

    # Get the pipe segment that contains the token
    let cursor_token = (char-to-token-index $ast $position) | default inf
    let segment = (
      $ast
      | where "index" <= $cursor_token
      | sort-by index -r
      | take until {|row| $row.shape in ["shape_pipe" "shape_closure"]}
      | where {|row| $row.shape in ["shape_internalcall" "shape_external"]}
    )

    if ($segment | is-empty) {
      null
    } else {
      # The command name is the first internal or external call in the segment
      $segment
        | first
        | {name: $in.content, type: (if $in.shape == "shape_internalcall" { "internal" } else {"external"})}
    }
}

# Expands a command if it is an alias (otherwise returns the command as-is)
export def expand-alias [command?: string]: [nothing -> string, string -> string] {
    let command = if ($command | is-not-empty) { $command } else { $in }
    let alias_info = (scope aliases | where name == $command)
    if ($alias_info | is-empty) { 
      return $command
    }
    $alias_info 
      | first 
      | get expansion 
      | ast $in --flatten 
      | first 
      | get content 
}

# Returns the name of the command closest to the cursor in the current buffer
export def current-command [] {
    command-at-position (commandline) (commandline get-cursor)
}


export def current-candidates [] {
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
    let prev_token_shape = (
      if ($cursor_token_index == 0) {
        null
      } else if $cursor_token_index == null {
        $ast | last | get shape
      } else {
        $ast | get ($cursor_token_index - 1) | get shape
      }
    )

    # TODO: PATH is a safe default for positional args unless they have pre-defined completion values
    match $prev_token_shape { 
      "shape_internalcall" | "shape_external" => {
        "SUBCOMMAND_OR_ARG_OR_FLAG"
      }
      "shape_flag" => {
        # TODO: infer the real value by getting the info for $command and using the `role` column
        let flag_takes_arguments = false 
        if $flag_takes_arguments {
          # TODO: handle case where arg takes fixed set of values (builtin completion now handles this; can look at implementation)
          #  scope commands | where name == "table" | get signatures | first | values | first | where parameter_name == "theme" | first | get completion  
          "FLAG_ARG"
        } else {
          "ARG_OR_FLAG"
        }
      }
      null | "shape_pipe" | "shape_closure" => {
        "COMMAND"
      }
      _ => {
        $prev_token_shape
        # "ARG_OR_FLAG"
      }
    }
}
