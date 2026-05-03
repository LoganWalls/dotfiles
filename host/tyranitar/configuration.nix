{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Add CPU/GPU-specific modules from inputs.hardware.nixosModules.* once
    # the hardware is known (e.g. common-cpu-intel, common-cpu-amd, common-pc-ssd).
    ./hardware-configuration.nix
  ];

  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  networking = {
    hostName = "tyranitar";
    firewall = {
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };

  users.users = {
    logan = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEVj2KaxvkBVVDcMxcdhESfE80L38xXZN42jb8XfhUI logan"
      ];
      extraGroups = ["wheel"];
    };
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    tailscale.enable = true;
  };

  system.stateVersion = "25.05";
}
