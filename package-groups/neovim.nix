{pkgs}:
with pkgs; [
  # Give neovim access to a C compiler for tree-sitter grammars
  (neovim.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [stdenv.cc.cc];
  }))
  xclip # work with the system clipboards

  ### Lanugage Servers / Tools
  # Shell
  shellcheck # linter
  shfmt # formatter

  # Nix
  nil # language server
  nix-direnv # nix intergration for direnv
  alejandra # black-inspired formatting
  statix # linter

  # C
  cmake

  # Python
  uv # python package / env manager
  (python3.withPackages (ps: with ps; [ipython])) # base interpreter
  pyright # language server for static type analysis
  ruff # language server for everything else

  # TOML
  taplo

  # Lua
  lua-language-server
  stylua # formatter

  # Docker
  nodePackages.dockerfile-language-server-nodejs

  # Web
  nodePackages.vscode-langservers-extracted
  nodePackages.typescript
  nodePackages.typescript-language-server
  nodePackages.prettier # formatter
  tailwindcss-language-server

  # Typst
  typst
  tinymist # language server
  typstfmt
  vale # "linter" for prose

  # Tex
  # texlive.combined.scheme-full # tex distribution
  # texlab # language server for tex

  # Other
  buf # protobuf
]
