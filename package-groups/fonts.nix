{pkgs, ...}:
with pkgs;
  [
    apple-fonts
    comic-mono
    crimson-pro
    fira-go
    fira-sans
    ibm-plex
    iosevka-comfy.comfy
    noto-fonts-color-emoji
    sf-mono-liga
    ligalex-mono
    maple-mono
  ]
  ++ (with pkgs.nerd-fonts; [
    fira-code
    jetbrains-mono
    overpass
    symbols-only
  ])
