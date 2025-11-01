use lib.nu filtered-dirs

export def list-sessions [] {
  wezterm cli list --format json 
  | from json 
  | get workspace 
  | uniq
  | wrap name
}

export def switch-to-session [name: string] {
  print -r $'(ansi osc)1337;SetUserVar=SWITCH_WEZTERM_WORKSPACE=($name | base64)(ansi st)'
}

export def sessionize [] {
  let picked = list-sessions
  | insert exists true
  | join --outer (
    ls ~/Projects
    | rename --column {name: path}
    | select path 
    | insert name {|it| $it.path | path basename}
    ) name
  | default false exists
  | sk --format {get name}

  if ($picked | is-not-empty) {
    if not $picked.exists {
      wezterm cli spawn --new-window --workspace $picked.name --cwd $picked.path
    } 
    switch-to-session $picked.name
  }
}
