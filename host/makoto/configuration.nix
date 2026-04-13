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
  imports = [../../modules/kanata/module.nix];

  services.kanata = {
    enable = true;
    configFile = "/Users/logan/.config/kanata/default.kbd";
  };

  system.primaryUser = "logan";
  environment.systemPackages =
    packageGroups.neovim
    ++ packageGroups.shell
    ++ (with pkgs; [
      age
      ffmpeg
      imagemagick
      macchina
      nh
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
      "obsidian"
      "orion"
      "slack"
      "steam"
      "tailscale-app"
      "zed"
      "zotero"
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
    gc.automatic = true;
    optimise.automatic = true;
  };

  system.defaults = {
    dock = {
      appswitcher-all-displays = true;
      autohide = true;
      mineffect = "scale";
      showAppExposeGestureEnabled = true;
    };
    universalaccess.reduceMotion = true;
  };
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  nixpkgs.hostPlatform = platform;
}
