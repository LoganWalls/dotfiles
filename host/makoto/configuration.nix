# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware), use something like:
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # It's strongly recommended you take a look at
    # https://github.com/nixos/nixos-hardware
    # and import modules relevant to your hardware.

    # Import your generated (nixos-generate-config) hardware configuration
    # ./hardware-configuration.nix

    # You can also split up your configuration and import pieces of it here.
  ];

  networking.hostName = "makoto";

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    configureBuildUsers = true;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      extra-platforms = "x86_64-darwin aarch64-darwin";
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      meslo-lgs-nf # reccomended font for p10k
      apple-fonts
      noto-fonts-emoji
      sf-mono-liga
      crimson-pro
      iosevka-comfy.comfy
      fira-go
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Overpass" "NerdFontsSymbolsOnly" ]; })
    ];
  };

  # Make sure an editor is always available
  environment.systemPackages = [ pkgs.vim ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      show-process-indicators = true;
      dashboard-in-overlay = false; # Don't show dashboard as a space
      show-recents = false; # Don't show recently used apps
      mru-spaces = false; # Don't rearrange based on recent use
      mineffect = "scale"; # Use a quicker minimization effect
    };
    finder = {
      AppleShowAllExtensions = true; # Show all file extensions
      CreateDesktop = false; # Don't show icons on the desktop
    };
  };
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  services = {
    nix-daemon.enable = true; # Auto upgrade nix package and the daemon service.
    emacs = {
      enable = true;
      package = pkgs.my-emacs;
      # NOTE: This path is relative to pkgs.my-emacs/bin
      # see: https://github.com/LnL7/nix-darwin/blob/a6b23918a72c891b2f8c683061193b8dd84550e4/modules/services/emacs.nix#L48
      exec = "../Applications/Emacs.app/Contents/MacOS/Emacs";
      # Add the bin path for the active nix profile so that Emacs
      # can find all of the software installed by home-manager
      additionalPath = [ "/Users/logan/.nix-profile/bin" ];
    };
    skhd.enable = true; # Hotkey daemon
    yabai = {
      enable = true; # Tiling window manager
      package = pkgs.yabai;
      enableScriptingAddition = false;
      config = {
        focus_follows_mouse = "off";
        mouse_follows_focus = "off";
        window_placement = "second_child";
        window_opacity = "off";
        window_border = "off";
        split_ratio = "0.50";
        auto_balance = "off";
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        layout = "bsp";
        top_padding = 20;
        bottom_padding = 20;
        left_padding = 20;
        right_padding = 20;
        window_gap = 20;
      };
      extraConfig = ''
        yabai -m rule --add app='System Settings' manage=off
        yabai -m rule --add app='Zoom' manage=off
      '';
    };

    # Commented because managed manually for now
    # homebrew = {
    #   enable = true;
    #   casks = ["blender" "chromium" "docker" "gimp" "inkscape" "spotify" "qlmarkdown"];
    # };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
