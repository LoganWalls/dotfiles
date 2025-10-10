{
  inputs,
  pkgs,
  homeDirectory,
  ...
}: let
  nushellWrapped =
    if pkgs.stdenv.isDarwin
    then
      (pkgs.nushell.overrideAttrs (old: {
        # Override forces nushell to use XDG paths (defaults to Application Support on macOS)
        buildInputs = old.buildInputs ++ [pkgs.makeWrapper];
        postInstall =
          old.postInstall
          or ""
          + ''
            wrapProgram "$out/bin/nu" --set XDG_CONFIG_HOME "${homeDirectory}/.config"
          '';
      }))
    else pkgs.nushell;
  zjstatus = inputs.zjstatus.packages."${pkgs.stdenv.system}".default;
in
  with pkgs; [
    nushellWrapped
    nushellPlugins.skim
    zellij
    zjstatus

    # REPL / UI
    carapace
    direnv
    nix-direnv
    starship
    vivid # ls_colors
    zoxide

    # Tools
    bat # cat with highlighting
    btop # system activity monitor
    delta # modern diff
    eza # modern ls
    fd # modern find
    flavours # base24 colorscheme management
    git
    gitui # a nice git TUI
    glow # pretty highlighting for markdown on CLI
    just # command runner
    librsvg # allows rasterizing SVGs
    mosh # nice ssh sessions
    ripgrep # modern grep
    sd # modern sed
    tealdeer # tldr for manpages
    ugrep # faster grep with backward-compatible interface
    viu # view images using kitty image protocol
  ]
