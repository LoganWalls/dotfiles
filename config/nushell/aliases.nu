alias vi = nvim
alias cat = bat
alias man = batman
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
alias tree = exa --tree --level=3 --ignore-glob='__pycache__/*|node_modules/*'

alias icat = wezterm imgcat
alias isvg = rsvg-convert | wezterm imgcat

alias grep = ugrep --sort -G -U -Y -. -Dread -dread
alias egrep = ugrep --sort -E -U -Y -. -Dread -dread
alias fgrep = ugrep --sort -F -U -Y -. -Dread -dread
alias zgrep = ugrep --sort -G -U -Y -z -. -Dread -dread
alias zegrep = ugrep --sort -E -U -Y -z -. -Dread -dread
alias zfgrep = ugrep --sort -F -U -Y -z -. -Dread -dread
