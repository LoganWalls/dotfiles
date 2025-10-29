use lib.nu [filtered-files, filtered-dirs]
use images.nu icat

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
alias tree = exa --tree --level=3 --git-ignore --icons=auto

alias grep = ugrep --sort -G -U -Y -. -Dread -dread
alias egrep = ugrep --sort -E -U -Y -. -Dread -dread
alias fgrep = ugrep --sort -F -U -Y -. -Dread -dread
alias zgrep = ugrep --sort -G -U -Y -z -. -Dread -dread
alias zegrep = ugrep --sort -E -U -Y -z -. -Dread -dread
alias zfgrep = ugrep --sort -F -U -Y -z -. -Dread -dread
