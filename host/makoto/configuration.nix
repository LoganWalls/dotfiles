{
  self,
  pkgs,
  inputs,
  config,
  ...
}: let
  inherit (pkgs) lib;
  platform = "aarch64-darwin";
  packageGroups = import ../../package-groups/default.nix {
    inherit inputs pkgs;
    homeDirectory = "/Users/logan";
  };
in {
  system.primaryUser = "logan";
  environment.systemPackages =
    packageGroups.neovim
    ++ packageGroups.shell
    ++ (with pkgs; [
      age
      ffmpeg
      imagemagick
      kanata
      inputs.kanata-tray.packages.${platform}.default
      macchina
    ]);
  fonts.packages = packageGroups.fonts;

  homebrew = {
    enable = true;
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap";
    };
    casks = [
      "discord"
      "firefox"
      "ghostty"
      "gimp"
      "google-chrome"
      "inkscape"
      "orion"
      "slack"
      "steam"
      "tailscale-app"
      "zed"
    ];
  };

  # Do not touch the system shell
  programs.zsh.enable = false;

  nix = {
    # Add each flake input as a registry to make nix3 commands consistent with this flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    # Add inputs to the system's legacy channels
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings.experimental-features = "nix-command flakes";
  };
  system.configurationRevision = self.rev or self.dirtyRev or null;
  nixpkgs.hostPlatform = platform;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
