{
  config,
  lib,
  stdenv,
  pkgs,
  ...
}: rec {
  xdg.enable = true;
  home = {
    username = "logan";
    homeDirectory = "/Users/logan";
    sessionVariables = {
      DOTFILES = "$HOME/.dotfiles/";
      NIX_PATH = "nixpkgs=flake:nixpkgs";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    stateVersion = "21.11";

    packages = with pkgs; [
      git

      ### GUI Apps
      wezterm
      (nushell.overrideAttrs (old: {
        # Override forces nushell to use XDG paths (defaults to Application Support on macOS)
        buildInputs = old.buildInputs ++ [makeWrapper];
        postInstall =
          old.postInstall
          or ""
          + ''
            wrapProgram "$out/bin/nu" --set XDG_CONFIG_HOME "${home.homeDirectory}/.config"
          '';
      }))
      nushellPlugins.skim
      (neovim.overrideAttrs (old: {
        propagatedBuildInputs =
          (old.propagatedBuildInputs or [])
          ++ [
            pkgs.stdenv.cc.cc # C compiler for tree-sitter grammars
          ];
      }))
      starship
      carapace
      direnv
      nix-direnv
      zoxide

      ### Shell tools
      age # encryption
      btop # system activity monitor
      bat # cat with highlighting
      bat-extras.batman # use bat to highlight manpages
      coreutils-prefixed # for compat with emacs
      eza # modern ls
      delta # modern diff
      fd # modern find
      flavours # base24 colorscheme management
      sd # modern sed
      ripgrep # modern grep
      just # command runner
      ugrep # faster grep with backward-compatible interface
      tealdeer # tldr for manpages
      macchina # more performant neofetch alternative
      # mosh # nice ssh sessions
      gitui # a nice git TUI
      vivid # ls_colors
      xclip # work with the system clipboards

      ### File format-specific tools
      jq # work with json files
      xsv # work with (c/t)sv files
      imagemagick # work with images
      ffmpeg # work images, audio, and video
      librsvg # allows rasterizing SVGs

      ##### Language-specific
      ### Shell
      shellcheck # linter
      shfmt # formatter

      ### Nix
      nil # language server
      nix-direnv # nix intergration for direnv
      alejandra # black-inspired formatting
      statix # linter

      ### C
      cmake

      ### Python
      uv # python package / env manager
      (python3.withPackages (ps: with ps; [ipython])) # base interpreter
      pyright # language server for static type analysis
      ruff-lsp # language server for everything else

      ### TOML
      taplo

      ### Lua
      lua-language-server
      stylua # formatter

      ### Docker
      nodePackages.dockerfile-language-server-nodejs

      ### Web
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier # formatter

      ### Tex
      # texlive.combined.scheme-full # tex distribution
      # texlab # language server for tex

      ### Typst
      typst
      tinymist # language server
      typstfmt
      zathura # pdf viewer

      ### Other
      buf-language-server # protobuf

      ### Prose / writing
      vale # "linter" for prose

      ### Fonts
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
    ];
  };

  programs = {
    home-manager.enable = true;
  };
}
