use std/util "path add"

let nix_profile = $"($nu.home-path)/.nix-profile";

$env.PATH ++= [$"($nix_profile)/bin", '/nix/var/nix/profiles/default/bin', $"($nu.home-path)/.docker/bin/"]
path add '/opt/homebrew/bin'

$env.XDG_DATA_DIRS = (
  ($env | get -o XDG_DATA_DIRS | default '/usr/local/share:/usr/share') 
  | split row (char esep)
  | append $"($nix_profile)/share" 
  | append '/nix/var/nix/profiles/default/share'
)
$env.MANPATH = ($env.MANPATH | split row (char esep) | where {|x| $x | is-not-empty} | append $"($nix_profile)/share/man")

if ($env | get -o NIX_SSL_CERT_FILE | is-empty) {
  let user_nix_ssl = $"($nix_profile)/etc/ssl/certs/ca-bundle.crt"
  $env.NIX_SSL_CERT_FILE = if ($user_nix_ssl | path exists) { 
    $user_nix_ssl 
  } else {
    "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
  }
}

use hooks.nu
hooks carapace init
hooks starship init
hooks zoxide init

$env.EDITOR = "nvim"
$env.LS_COLORS = (vivid generate catppuccin-ansi)
$env.MANPAGER = "nvim +Man!";
