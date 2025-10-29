use lib.nu filtered-dirs

export def zellij-sessions [] {
  zellij list-sessions --no-formatting
  | lines
  | parse "{name} [Created {created} ago]{status}"
  | update created {|it|
    $it.created 
    | str replace "days" "day" 
    | str replace "h" "hr" 
    | str replace "m" "min" 
    | str replace "s" "sec" 
    | into duration 
  }
  | update status {|it|
    if ($it.status | find "EXITED" | is-not-empty) {
      "closed"
    } else if ($it.status | find "current" | is-not-empty) {
      "active"
    } else {
      "inactive"
    }
  }
  | sort-by created
}

export def zellij-sessionizer [] {
  let picked = zellij-sessions 
  | insert session {|it| $it.name}
  | select name session
  | join --outer (
    ls ~/Projects
    | select name 
    | insert session {|it| $it.name | path basename}
    ) session
  | upsert name {|it| $it.name | default $it.name_ }
  | reject name_
  | sk --format {get session}

  if ($picked | is-not-empty) {
    $picked | get name | path expand | print
    (
      zellij pipe 
        --plugin switch 
        -- $"--session ($picked | get session) --cwd ($picked | get name | path expand)" 
    )
  }
}
