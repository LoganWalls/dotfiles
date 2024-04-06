{
  config,
  lib,
  stdenv,
  pkgs,
  impurePath,
  basedpyright-ls,
  yazi,
  ...
}: let
  asSymlink = path: config.lib.file.mkOutOfStoreSymlink (impurePath path);
in {
  home = {
    username = "logan";
    homeDirectory = "/Users/logan";
    sessionVariables = {
      EDITOR = "nvim";
      DOTFILES = "$HOME/.dotfiles/";
      NIX_PATH = "nixpkgs=flake:nixpkgs";
    };

    file.emacs-init = {
      source = asSymlink ../../config/emacs/init.el;
      target = ".config/emacs/init.el";
    };
    file.emacs-early-init = {
      source = asSymlink ../../config/emacs/early-init.el;
      target = ".config/emacs/early-init.el";
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
      neovim
      nodejs-slim # for AI code completion in neovim

      ### Shell tools
      age # encryption
      bat # modern cat
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
      mosh # nice ssh sessions
      zoxide # jump to frequently used directories
      direnv # perform env setup when entering a directory
      gitui # a nice git TUI
      xclip # work with the system clipboards
      yazi # file manager
      zsh-history-substring-search # Search command history automatically

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
      poetry # environment management (poetry2nix)
      (python311.withPackages (ps: with ps; [ipython])) # base interpreter
      basedpyright-ls # improved fork of pyright
      nodePackages.pyright # language server for static type analysis
      ruff-lsp # language server for everything else

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
      texlive.combined.scheme-full # tex distribution
      texlab # language server for tex

      ### Typst
      typst
      typst-lsp
      typstfmt

      ### Other
      buf-language-server # protobuf

      ### Prose / writing
      vale # "linter" for prose

      ### Fonts: TODO: move to system config?
      ibm-plex
    ];
  };

  programs = {
    home-manager.enable = true;
    emacs = {
      enable = true;
      package = pkgs.my-emacs;
    };
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
    starship.enable = true;
    yazi = {
      enable = true;
      enableZshIntegration = true;
      package = yazi;
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
        yz = "yazi";

        emacs = "${pkgs.my-emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";

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
          name = "zsh-history-substring-search";
          src = zsh-history-substring-search;
          file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
        }
      ];
    };
  };
}
