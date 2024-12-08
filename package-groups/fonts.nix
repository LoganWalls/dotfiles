{pkgs}:
with pkgs;
  [
    apple-fonts
    comic-mono
    crimson-pro
    fira-go
    fira-sans
    ibm-plex
    iosevka-comfy.comfy
    noto-fonts-emoji
    sf-mono-liga
    ligalex-mono
  ]
  ++ (with pkgs.nerd-fonts; [
    fira-code
    jetbrains-mono
    overpass
    symbols-only
  ])
