use hooks.nu

hooks carapace init
hooks starship init
hooks zoxide init

$env.EDITOR = "nvim"
$env.LS_COLORS = (vivid generate catppuccin-mocha)
