{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    package = pkgs.neovim-nightly;
    plugins = [pkgs.vimPlugins.nvim-treesitter.withAllGrammars];
    # TODO: move LSPs here
    extraPackages = [];
  };
}
