use hooks.nu *

# Carapace
$env.CARAPACE_BRIDGES = 'zsh,bash'
source $carapace.path

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
use $starship.path

# Zoxide
source $zoxide.path
