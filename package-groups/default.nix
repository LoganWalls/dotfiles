{
  inputs,
  pkgs,
  homeDirectory,
}: {
  neovim = import ../package-groups/neovim.nix {inherit inputs pkgs;};
  shell = import ../package-groups/nushell.nix {inherit inputs pkgs homeDirectory;};
  fonts = import ../package-groups/fonts.nix {inherit inputs pkgs;};
}
