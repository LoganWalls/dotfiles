# Add nix and brew to PATH
$env.PATH = ($env.PATH | split row (char esep) | append $"($nu.home-path)/.nix-profile/bin" | append "/nix/var/nix/profiles/default/bin")
$env.PATH = ($env.PATH | split row (char esep) | prepend '/opt/homebrew/bin')

use hooks.nu
hooks carapace init
hooks starship init
hooks zoxide init

$env.LS_COLORS = (vivid generate catppuccin-mocha)
$env.EDITOR = "nvim"
$env.MANPAGER = "nvim +Man!";
