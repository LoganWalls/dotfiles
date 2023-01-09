{
  config,
  lib,
  stdenv,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "logan";
  home.homeDirectory = "/Users/logan";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    alacritty # Terminal emulator

    ### Editors
    my-emacs # GUI goodness (see ../../overlay/emacs.nix)
    neovim # text editor

    ### Shell tools
    age # encryption
    bat # modern cat
    exa # modern ls
    delta # modern diff
    fd # modern find
    sd # modern sed
    ripgrep # modern grep
    xh # modern curl
    just # command runner
    ugrep # faster grep with backward-compatible interface
    tealdeer # tldr for manpages
    neofetch # display system info
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
    python39 # base interpreter
    python39Packages.black # code formatting
    python39Packages.isort # import sorting
    python39Packages.flake8 # linting
    python39Packages.ipython # nice interpreter
    nodePackages.pyright # language server

    ### Lua
    stylua # code formatting

    ### Docker
    nodePackages.dockerfile-language-server-nodejs

    ### Web
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier # formatter

    ### Tex
    tectonic # latex engine
    texlab # language server for tex
    my-texlive # packages, utils, and classes

    ### Prose / writing
    papis # reference manager
    vale # "linter" for English
    zathura # PDF viewer
    zola # static-site generator for .md files
  ];

  programs.git = {
    enable = true;
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
    delta.enable = true;
    extraConfig = {
      url = {"git@github.com:" = {insteadOf = "https://github.com/";};};
      init.defaultBranch = "main";
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";
    fileWidgetCommand = "fd --type f";
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    # EDITOR = "emacsclient -c";
    TMUX_THEME = "tokyonight-night";
    REFERENCE_BIB = "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Knowledge/references.bib";
    DOTFILES = "$HOME/.dotfiles/";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
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
      emacs = "${pkgs.my-emacs}/Applications/Emacs.app/Contents/MacOS/Emacs";
      e = "emacsclient -c";
      fda = "fd -IH";
      ls = "exa --icons";
      l = "ls";
      ll = "exa --all --icons";
      lll = "exa --all --long --icons";
      tree = "exa --tree --level=3 --ignore-glob='__pycache__'";
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";

      icat = "kitty +kitten icat";
      isvg = "rsvg-convert | icat";

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
      eval "$(_PAPIS_COMPLETE=source_zsh papis)"  # completions for papis
    '';
    plugins = with pkgs; [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ../../programs/zsh/p10k;
        file = ".p10k-minimal.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];
  };
}
