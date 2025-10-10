alias vi = nvim
alias cat = bat
alias fda = fd -IH
alias gu = gitui
alias lsa = ls --all

def icon-grid [] {
  sort-by type name -i | grid --color --icons -w 100
}
def l [] {
  ls | icon-grid
}
def ll [] {
  ls --all | icon-grid
}
alias lll = ls --all --long
alias tree = exa --tree --level=3 --git-ignore

alias viu = viu --transparent

# View SVGs in the terminal
def svgcat [
  path?: path, # The SVG file to read (defaults to STDIN)
  --dpi: int = 96, # DPI to use when rasterizing the SVG
  --zoom: int = 6, # Zoom factor to use when rasterizing the SVG
  ...args # Remaining arguments are passed to `viu`
] {
    let input = if ($path | is-not-empty) { cat $path } else { $in }
    $input | rsvg-convert --dpi-x $dpi --dpi-y $dpi --zoom $zoom | viu - ...$args
}
# View images in the terminal
def icat [
    path?: path, # The file to read (defaults to STDIN)
    ...args # Remaining arguments are passed to `viu`
  ] {
    if ($path | is-empty) {
      $in | viu - ...$args
    } else if (($path | path parse | get extension) == "svg") {
      svgcat $path ...$args
    } else {
      viu $path ...$args
    }
  }

alias grep = ugrep --sort -G -U -Y -. -Dread -dread
alias egrep = ugrep --sort -E -U -Y -. -Dread -dread
alias fgrep = ugrep --sort -F -U -Y -. -Dread -dread
alias zgrep = ugrep --sort -G -U -Y -z -. -Dread -dread
alias zegrep = ugrep --sort -E -U -Y -z -. -Dread -dread
alias zfgrep = ugrep --sort -F -U -Y -z -. -Dread -dread
