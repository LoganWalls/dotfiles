{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
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

  networking.hostName = "sebastian";
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
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    tailscale.enable = true;
  };

  programs = {
    neovim.enable = true;
    mosh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ripgrep
    fd
  ];

  system.stateVersion = "22.05";
}
