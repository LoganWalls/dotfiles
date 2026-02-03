use lib.nu init-path

export module carapace {
  export const path = $"($nu.home-dir)/.cache/carapace/init.nu"
  export def init [] {
    carapace _carapace nushell | save -f (init-path $path)
  }
}

export module starship {
  export const path = $"($nu.home-dir)/.cache/starship/init.nu"
  export def init [] {
    starship init nu | save -f (init-path $path)
  }
}

export module zoxide {
  export const path = $"($nu.home-dir)/.cache/zoxide/init.nu"
  export def init [] {
    zoxide init nushell | save -f (init-path $path)
  }
}

