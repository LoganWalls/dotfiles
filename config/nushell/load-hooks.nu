use hooks.nu

# Carapace
$env.CARAPACE_BRIDGES = 'zsh,bash'
source $hooks.carapace.path

# Direnv
$env.config.hooks.pre_prompt = (
  $env.config.hooks.pre_prompt | append ({ || 
    if (which direnv | is-empty) {
      return
    }
    direnv export json | from json | default {} | load-env
  })
)

# Starship
use $hooks.starship.path

# Zoxide
source $hooks.zoxide.path
