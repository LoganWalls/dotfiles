# Add nix to PATH
$env.PATH = ($env.PATH | split row (char esep) | append $"($nu.home-path)/.nix-profile/bin" | append "/nix/var/nix/profiles/default/bin")

use hooks.nu
hooks carapace init
hooks starship init
hooks zoxide init

$env.EDITOR = "nvim"
$env.LS_COLORS = (vivid generate catppuccin-mocha)
