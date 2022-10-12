# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  home = {
    username = "logan";
    homeDirectory = "/home/logan";

    # Add stuff for your user as you see fit:
    packages = with pkgs; [
      kitty # terminal
      wofi # launcher
      wl-clipboard # enable copy/paste on wayland
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = true;
      QT_QPA_PLATFORM = "wayland";
    };
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    firefox = let
      addons = pkgs.nur.repos.rycee.firefox-addons;
    in {
      enable = true;
      package = pkgs.firefox-wayland;
      extensions = with addons; [
        ublock-origin
      ];
      profiles.logan = {
	name = "Logan";
        settings = {
          "browser.startup.homepage" = "https://start.duckduckgo.com";
          "identity.fxaccounts.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "dom.security.https_only_mode" = true;
          # "signon.rememberSignons" = false;
          "browser.topsites.blockedSponsors" = ''["amazon"]'';
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.disableResetPrompt" = true;
        };
      };
    };
  };

  # Enable Sway
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      startup = [
        # https://github.com/NixOS/nixpkgs/issues/119445
        {command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK";}
        {command = "for_window [class=\"Firefox\"] fullscreen enable";}
        {command = "firefox --kiosk https://google.com";}
      ];
      terminal = "kitty";
      menu = "wofi --show run";
      # Display device configuration
      output = {
        eDP-1 = {
          # Set HIDP scale (pixel integer scaling)
          scale = "3";
        };
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
