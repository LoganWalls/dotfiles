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
      EDITOR = "nvim";
      DOTFILES = "$HOME/.dotfiles/";
      NIX_PATH = "nixpkgs=flake:nixpkgs";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    stateVersion = "21.11";

    packages = with pkgs; [
      ### GUI Apps
      wezterm

      ### Editors
      neovim # text editor

      ### Shell tools
      age # encryption
      bat # modern cat
      btop # system activity monitor
      coreutils-prefixed # for compat with emacs
      eza # modern ls
      delta # modern diff
      fd # modern find
      sd # modern sed
      ripgrep # modern grep
      just # command runner
      ugrep # faster grep with backward-compatible interface
      tealdeer # tldr for manpages
      macchina # more performant neofetch alternative
      mosh # nice ssh sessions
      zoxide # jump to frequently used directories
      direnv # perform env setup when entering a directory
      gitui # a nice git TUI
      xclip # work with the system clipboards
      zsh-history-substring-search # Search command history automatically
      zsh-powerlevel10k # Shell theme

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
      rnix-lsp # language server
      nix-direnv # nix intergration for direnv
      alejandra # black-inspired formatting
      statix # linter

      ### C
      cmake

      ### Python
      poetry # environment management (poetry2nix)
      (python311.withPackages (ps: with ps; [ipython])) # base interpreter
      nodePackages.pyright # language server for static type analysis
      ruff-lsp # language server for everything else

      ### Lua
      lua-language-server

      ### Docker
      nodePackages.dockerfile-language-server-nodejs

      ### Web
      nodePackages.vscode-langservers-extracted
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier # formatter

      ### Tex
      texlive.combined.scheme-full # tex distribution
      texlab # language server for tex
      zathura # PDF viewer

      ### Other
      buf-language-server # protobuf

      ### Prose / writing
      ibm-plex # font TODO: move this to darwin config
      vale # "linter" for prose
    ];
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
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
      attributes = [
        "*.org   diff=org"
      ];
      delta.enable = true;
      extraConfig = {
        url = {"git@github.com:" = {insteadOf = "https://github.com/";};};
        init.defaultBranch = "main";
        diff.org = {
          xfuncname = "^(\\*+ +.*)$";
        };
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
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
      shellAliases = {
        dots = "gitui --directory $DOTFILES --workdir $HOME";
        gdots = "git --git-dir=$DOTFILES --work-tree=$HOME";
        cat = "bat";
        fda = "fd -IH";
        gu = "gitui";
        ls = "exa --icons";
        l = "ls";
        ll = "exa --all --icons";
        lll = "exa --all --long --icons";
        tree = "exa --tree --level=3 --ignore-glob='__pycache__/*|node_modules/*'";
        vi = "nvim";
        vim = "nvim";
        vimdiff = "nvim -d";

        icat = "wezterm imgcat";
        isvg = "rsvg-convert | wezterm imgcat";

        grep = "ugrep --sort -G -U -Y -. -Dread -dread";
        egrep = "ugrep --sort -E -U -Y -. -Dread -dread";
        fgrep = "ugrep --sort -F -U -Y -. -Dread -dread";

        zgrep = "ugrep --sort -G -U -Y -z -. -Dread -dread";
        zegrep = "ugrep --sort -E -U -Y -z -. -Dread -dread";
        zfgrep = "ugrep --sort -F -U -Y -z -. -Dread -dread";
      };
      initExtra = ''
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      '';
      plugins = with pkgs; [
        {
          name = "powerlevel10k";
          src = zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = lib.cleanSource ../../programs/zsh/p10k;
          file = ".p10k-minimal.zsh";
        }
        {
          name = "zsh-history-substring-search";
          src = zsh-history-substring-search;
          file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
        }
      ];
    };
  };
}
