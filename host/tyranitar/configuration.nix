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

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-c4fd9340-9f7a-40bb-add8-6c8a04f48f8b".device = "/dev/disk/by-uuid/c4fd9340-9f7a-40bb-add8-6c8a04f48f8b";

  networking = {
    hostName = "tyranitar";
    networkmanager.enable = true;
    useDHCP = false;
    firewall = {
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
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

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.logan = {
    isNormalUser = true;
    description = "logan";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "video" "render"];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEVj2KaxvkBVVDcMxcdhESfE80L38xXZN42jb8XfhUI logan"
    ];
    packages = with pkgs; [

    ];
  };

  virtualisation.libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
	    swtpm.enable = true;
      };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  system.stateVersion = "25.11";
}
