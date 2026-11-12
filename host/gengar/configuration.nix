{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  # Playwright MCP server with a persistent Chromium profile (cookies/logins survive restarts).
  playwright-mcp-persistent = pkgs.writeShellScriptBin "playwright-mcp-persistent" ''
    profile="''${XDG_DATA_HOME:-$HOME/.local/share}/playwright-mcp/profile"
    mkdir -p "$profile"
    export PLAYWRIGHT_MCP_USER_DATA_DIR="$profile"
    exec ${lib.getExe pkgs.playwright-mcp} --headless --browser chromium "$@"
  '';
in {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../../modules/nixos/git.nix
  ];

  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  networking = {
    hostName = "gengar";
    firewall = {
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };

  # Headless server: never suspend (sleeping drops SSH and the exit node).
  systemd.targets = lib.genAttrs ["sleep" "suspend" "hibernate" "hybrid-sleep"] (_: {enable = false;});
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    IdleAction = "ignore";
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AuthenticationMethods = "publickey";
      };
    };
    tailscale = {
      enable = true;
      # Enables IP forwarding + loose reverse-path filtering needed for an exit node.
      useRoutingFeatures = "server";
      extraSetFlags = ["--advertise-exit-node"];
    };
  };

  # Users only exist declaratively, and nobody has a password: SSH keys are the only way in.
  users.mutableUsers = false;
  users.users = {
    root.hashedPassword = "!";
    logan = {
      isNormalUser = true;
      hashedPassword = "!";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEVj2KaxvkBVVDcMxcdhESfE80L38xXZN42jb8XfhUI logan"
      ];
      extraGroups = ["wheel"];
    };
  };
  # No passwords exist, so sudo can't ask for one.
  security.sudo.wheelNeedsPassword = false;

  # Register the Playwright MCP server with Claude Code for logan (user scope, idempotent).
  systemd.services.claude-playwright-mcp = {
    description = "Register Playwright MCP server with Claude Code";
    wantedBy = ["multi-user.target"];
    path = [pkgs.llm-agents.claude-code playwright-mcp-persistent];
    serviceConfig = {
      Type = "oneshot";
      User = "logan";
      WorkingDirectory = "/home/logan";
    };
    environment.HOME = "/home/logan";
    script = ''
      # Point at the stable profile path so the entry survives rebuilds and GC.
      bin=/run/current-system/sw/bin/playwright-mcp-persistent
      if ! claude mcp get playwright 2>/dev/null | grep -qF "$bin"; then
        claude mcp remove --scope user playwright >/dev/null 2>&1 || true
        claude mcp add --scope user playwright -- "$bin"
      fi
    '';
  };

  # Fonts so headless Chromium renders pages and screenshots properly.
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
    ];
  };

  programs = {
    mosh.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    # Lets Claude Code / npx-launched tools run generic Linux binaries.
    nix-ld.enable = true;
  };

  environment.systemPackages = with pkgs; [
    llm-agents.claude-code
    playwright-mcp
    playwright-mcp-persistent
    nodejs
    gh
    ripgrep
    fd
    jq
    tmux
    nh
    uv
  ];

  # Repurposed orpheus install; keep its original state version.
  system.stateVersion = "22.05";
}
