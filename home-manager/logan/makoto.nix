{
  config,
  lib,
  stdenv,
  pkgs,
  ...
}: {
  home = {
    username = "logan";
    homeDirectory = "/Users/logan";
    sessionVariables = {
      DOTFILES = "$HOME/.dotfiles/";
      NIX_PATH = "nixpkgs=flake:nixpkgs";
    };
    shellAliases = {
      cat = "bat";
      man = "batman";
      fda = "fd -IH";
      gu = "gitui";
      ls = "exa --icons";
      l = "ls";
      ll = "exa --all --icons";
      lll = "exa --all --long --icons";
      tree = "exa --tree --level=3 --ignore-glob='__pycache__/*|node_modules/*'";

      # emacs = "${pkgs.my-emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";
      icat = "wezterm imgcat";
      isvg = "rsvg-convert | wezterm imgcat";

      grep = "ugrep --sort -G -U -Y -. -Dread -dread";
      egrep = "ugrep --sort -E -U -Y -. -Dread -dread";
      fgrep = "ugrep --sort -F -U -Y -. -Dread -dread";

      zgrep = "ugrep --sort -G -U -Y -z -. -Dread -dread";
      zegrep = "ugrep --sort -E -U -Y -z -. -Dread -dread";
      zfgrep = "ugrep --sort -F -U -Y -z -. -Dread -dread";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    stateVersion = "21.11";

    packages = with pkgs; [
      ### GUI Apps
      wezterm

      ### Shell tools
      age # encryption
      btop # system activity monitor
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
      xclip # work with the system clipboards

      ### File format-specific tools
      jq # work with json files
      xsv # work with (c/t)sv files
      imagemagick # work with images
      ffmpeg # work images, audio, and video

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
      (python311.withPackages (ps: with ps; [ipython])) # base interpreter
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
    # emacs = {
    #   enable = true;
    #   package = pkgs.my-emacs;
    # };
    git = {
      enable = true;
      lfs.enable = true;
      delta.enable = true;
      userEmail = "2934282+LoganWalls@users.noreply.github.com";
      userName = "Logan Walls";
      ignores = ["*~" ".DS_Store"];
      aliases = {
        cm = "commit";
        co = "checkout";
        st = "status";
        br = "branch";
        wip = "commit -m 'WIP'";
      };
      extraConfig = {
        url = {"git@github.com:" = {insteadOf = "https://github.com/";};};
        init.defaultBranch = "main";
        diff.org = {
          xfuncname = "^(\\*+ +.*)$";
        };
      };
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [batman];
    };
    carapace.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
    };
    starship.enable = true;
    zoxide.enable = true;
    nushell = {
      enable = true;
      # configFile.text = ''
      #   source ~/.config/nushell/config.nu
      #   source ~/.config/nushell/env.nu
      # '';
      # envFile.text = ''
      #   $env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
      # '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      defaultKeymap = "emacs";
      history = {
        size = 10000;
        save = 10000;
        ignoreDups = true;
        expireDuplicatesFirst = true;
        share = true;
      };
      initExtra = ''
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      '';
      plugins = with pkgs; [
        {
          name = "zsh-history-substring-search";
          src = zsh-history-substring-search;
          file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
        }
      ];
    };
  };
}
