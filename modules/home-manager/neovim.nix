{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    package = pkgs.neovim;
    # TODO: move LSPs here
    extraPackages = [
      pkgs.stdenv.cc.cc # C compiler for tree-sitter grammars
    ];
  };
}
