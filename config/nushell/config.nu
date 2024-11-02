source hooks/zoxide.nu
use hooks/starship.nu
source hooks/carapace.nu

$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt | append (source hooks/direnv/config.nu)
)
