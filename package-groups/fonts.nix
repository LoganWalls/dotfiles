{pkgs}:
with pkgs; [
  (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Overpass" "NerdFontsSymbolsOnly"];})
  apple-fonts
  comic-mono
  crimson-pro
  fira-go
  fira-sans
  ibm-plex
  iosevka-comfy.comfy
  noto-fonts-emoji
  sf-mono-liga
]
