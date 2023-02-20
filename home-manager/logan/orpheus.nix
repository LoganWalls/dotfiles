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
      rsync # sync files
      kitty # terminal
      wofi # launcher
      pavucontrol # audio control
      wl-clipboard # enable copy/paste on wayland
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
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
      profiles.logan = {
        name = "Logan";
        extensions = with addons; [
          multi-account-containers
          ublock-origin
          skip-redirect
        ];
        settings = {
          "browser.startup.homepage" = "file:///home/logan/orpheus-start-page/index.html";
          "ui.systemUsesDarkTheme" = true;

          # Force hardware acceleration
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;

          # Make UIs larger
          "font.size.systemFontScale" = 150;

          # Disable Firefox accounts
          "identity.fxaccounts.enabled" = false;

          # Enable HTTPS-Only Mode
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;

          # Privacy
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.partition.network_state.ocsp_cache" = true;

          # Disable telemetry
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "network.allow-experiments" = false;

          # "signon.rememberSignons" = false;
          "browser.topsites.blockedSponsors" = ''["amazon"]'';
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.disableResetPrompt" = true;

          # Disable Pocket
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "extensions.pocket.enabled" = false;
          "extensions.pocket.api" = "";
          "extensions.pocket.oAuthConsumerKey" = "";
          "extensions.pocket.showHome" = false;
          "extensions.pocket.site" = "";
        };
      };
    };
  };

  # Enable Sway
  wayland.windowManager.sway = {
    enable = true;
    swaynag.enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      for_window [app_id="firefox"] fullscreen enable
    '';
    config = {
      terminal = "kitty";
      menu = "wofi --show run";

      startup = [
        # Wait a moment for the network to connect
        {command = "sleep 1";}
        # Launch Firefox in full screen mode on start page.
        {command = "firefox";}
      ];
      # Display device configuration
      output = {
        eDP-1 = {
          # Set HIDP scale (pixel integer scaling)
          scale = "2";
        };
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
