# Returns the name of the command closest to `position` in `script`
export def command-at-position [script: string, position: int] {
    let ast = (ast $script --flatten | enumerate | flatten)
    if ($ast | is-empty) {
        return null
    }

    # Find the index of the token that contains the character at `position`
    let cursor_token = (
      $ast
      | where ($it.span.start <= $position) and ($position <= $it.span.end)
    )
    if ($cursor_token | is-empty) {
      return ""
    }
    let cursor_token = (
      $cursor_token
      | first
      | get "index"
    )

    # Get the pipe segment that contains the token
    let segment = (
      $ast
      | where "index" <= $cursor_token
      | sort-by index -r
      | take until {|row| $row.shape == 'shape_pipe'}
      | sort-by index
    )

    # The command name is the first internal or external call in the segment
    $segment
      | where shape in ['shape_internalcall' 'shape_external']
      | first
      | get -o content
}

# Returns the name of the command closest to the cursor in the current buffer
export def current-command [] {
    let buf = (commandline)
    # When the cursor is at the end of the line, it is past the end of the string
    # returned by `commandline`, so we just set it to the last character 
    let cursor = ([(commandline get-cursor) (($buf | str length) - 1)] | math min)

    command-at-position $buf $cursor
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
      --prompt $"($command) flags: "
      --height "30%"
      --format {
        $"($in.name | fill -w $flag_length)($in.type | fill -w $type_length)($in.usage)"
      })
    | default [{ name: "" }]
    | get name
    | str join " "
}


export def fuzzy-complete-dwim [] {
# TODO: implement based on the following flow:
# Preceding character is:
# command then space: subcommmand -> positional arguments 
# flag then space: 
#   does flag take args?
#   yes: complete over appropriate arg values
#   no: same as command then space
# -: flag
# start-of-line or ( or |: available commands

# 0. Custom-completion
# 1. Subcommand
# 2. Flag
# 3. Path (maybe file vs dir?)


    let script = (commandline)
    # When the cursor is at the end of the line, it is past the end of the string
    # returned by `commandline`, so we just set it to the last character 
    let cursor = ([(commandline get-cursor) (($script | str length) - 1)] | math min)

    let ast = (ast $script --flatten | enumerate | flatten)
    if ($ast | is-empty) {
        return null
    }


}
