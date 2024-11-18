{
  pkgs,
  homeDirectory,
}: {
  neovim = import ../package-groups/neovim.nix {inherit pkgs;};
  shell = import ../package-groups/nushell.nix {inherit pkgs homeDirectory;};
  fonts = import ../package-groups/fonts.nix {inherit pkgs;};
}
