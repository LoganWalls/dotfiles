# Gets all available (internal and external) commands
export def all-commands []: nothing -> table {
  let external_commands = (
    $env.PATH 
      | each --flatten {|it | try { ls --threads $it } } 
      | par-each {|it | 
          if ($it.type == symlink) { 
            $it | update name ($it.name | path expand) | update type file 
          } else { 
            $it 
          }
          | insert description ""
          # TODO: this info is nice to have, but this is too slow. Need to cache.
          # | insert description (carapace $in.name export | from json | default {Short: ""} | get Short | default "")
          # TODO: Can also get usage from tldr  
      } 
      | where type == file 
      | select name description
      | update name {|it| $it.name | path basename } 
      | uniq
  )
  let internal_commands = (
    scope commands
      | where {|it| not $it.is_sub}
      | select name description extra_description search_terms
  )

  $internal_commands 
    | insert type "internal"
    | append (
      $external_commands 
        | insert extra_description  "" 
        | insert search_terms ""
        | where {|it| not ($it.name in $internal_commands.name)}
        | insert type "external"
    )
    | sort-by name
}

export def "subcommands internal" [command: string]: nothing -> table {
  scope commands 
    | where is_sub and ($it.name | str starts-with $command)
    | select name description extra_description search_terms
}

export def "subcommands external" [command: string]: nothing -> table {
    let carapace_data = (
      carapace $command export 
        | from json
        | get -o Commands
    )
    if ($carapace_data | is-empty) {
      return null
    }

    $carapace_data
      | each --flatten {|it|
        [$it.Name] 
        | (append $it.Aliases? | default [])
        | each {|name| 
          {name: $name, description: ($it.Short? | default "")}
        }
      }
      | insert extra_description  "" 
      | insert search_terms ""
}

export def "parameter-values external" [command: string, parameter: string]: nothing -> list<string> {
  # TODO: check if carapace or other completion libraries offer this
  []
}

export def "parameter-values internal" [command: string, parameter: string]: nothing -> list<string> {
  try {   
    scope commands 
      | where name == $command 
      | get signatures 
      | first 
      | values 
      | first 
      | where parameter_name == $parameter
      | first 
      | get -o completion
      | default []
   } catch { |err|
      if ($err.msg | str starts-with "Row number too large") {
        []
      } else {
        error make $err
      }
   }
}

# Splits the long and short versions of each flag into separate entries
# and formats them nicely for fuzzy finding
def format-flags []: table -> table {
  let flags = $in
  $flags 
    | compact short_name
    | update short_name {|it| $"-($it.short_name)" }
    | rename --column {shorthand: name} 
    | append (
      $flags 
        | compact long_name
        | update long_name {|it| $"--($it.long_name)" }
        | rename --column {long_name: name}
    )
}

export def "flags external" [command: string]: nothing -> table {
  let carapace_data = (carapace $command export | from json)
  if ($carapace_data | is-empty) {
    return null
  }

  $carapace_data
    | get LocalFlags
    | rename --block {str downcase}
    | rename --column {shorthand: short_name, longhand: long_name, usage: description}
    | insert role {|it| 
      if ($it.type == "string") {
        "named"
      } else {
        "switch"
      }
    }
    | format-flags
}


export def "flags internal" [command: string]: nothing -> table {
  let flags = try {
    scope commands 
      | where name == $command 
      | get signatures 
      | values 
      | reduce { |it, acc | $acc | append $it } 
      | where parameter_type in [switch named]
      | rename --column {parameter_name: long_name, short_flag: short_name, syntax_shape: type, parameter_type: role}
      | default "bool" type
      | select -o long_name short_name type description role
      | uniq
   } catch { |err|
      if ($err.msg | str starts-with "Row number too large") {
        null
      } else {
        error make $err
      }
   }

  if ($flags | is-empty) {
    null
  } else {
    $flags | format-flags
  }
}

