# Initialize a path if it does not exist
export def init-path [path?: path]: [
    nothing -> path
    path -> path
] {
  let path: path = (if ($in != null) { $in } else { $path })
  let parent = $path | path dirname
  if not ($parent | path exists) {
    mkdir $parent
  }
  $path
}

# Get a list of directories, respecting .gitignore
# Extra flags are passed to `fd`
export def --wrapped filtered-dirs [path: path = ".", ...rest] {
  let path: path = (if ($in != null) { $in } else { $path })
  fd --type dir --print0 --glob ...$rest "*" $path
  | split row (char -u '0000')
  | compact --empty
  | ls -D ...$in
}

# Get a list of files, respecting .gitignore
# Extra flags are passed to `fd`
export def --wrapped filtered-files [path: path = ".", ...rest] {
  let path: path = (if ($in != null) { $in } else { $path })
  fd --type file --print0 --glob "*" ...$rest $path
  | split row (char -u '0000')
  | compact --empty
  | ls ...$in
}


# Fuzzy find over directories
export def pick-dirs [] {
  filtered-dirs --max-depth=3
  | (
    sk 
    --format {get name}
    --preview {get name | eza --tree --level=2 --git-ignore --icons=always --color=always}
    --prompt '󰥨 '
  )
  | default {name: ""}
  | get name
}

# Fuzzy find over files
export def pick-files [] {
  filtered-files --max-depth=4
  | (
    sk 
    --format {get name}
    --preview {bat --force-colorization ($in | get name)}
    --prompt '󰈞 '
  )
  | default {name: ""}
  | get name
}
