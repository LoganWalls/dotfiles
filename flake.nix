{
  description = "My personal nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # TODO: remove when https://github.com/NixOS/nixpkgs/issues/450861 is fixed
    nixpkgs-old.url = "github:NixOS/nixpkgs/c9bd50a653957ee895ff8b6936864b7ece0a7fb6";
    hardware.url = "github:nixos/nixos-hardware";

    flakey-profile.url = "github:lf-/flakey-profile";

    zjstatus.url = "github:dj95/zjstatus";
    zjstatus.inputs.nixpkgs.follows = "nixpkgs";

    zellij-switch.url = "github:LoganWalls/zellij-switch";
    zellij-switch.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    sf-mono-liga = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flakey-profile,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in rec {
    overlays = {
      default = import ./overlay {inherit inputs;};
      emacs = inputs.emacs-overlay.overlay;
      neovim = inputs.neovim-nightly-overlay.overlays.default;
    };

    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    devShells = forAllSystems (system: {
      default = legacyPackages.${system}.callPackage ./shell.nix {};
    });

    legacyPackages = forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;

          # NOTE: Using `nixpkgs.config` in NixOS config won't work
          # Instead, set nixpkgs configs here
          # (https://nixos.org/manual/nixpkgs/stable/#idm140737322551056)
          config.allowUnfree = true;
        }
    );

    packages = forAllSystems (system: let
      pkgs = legacyPackages."${system}";
    in {
      profile.logan =
        pkgs.callPackage ./profiles/logan.nix {inherit pkgs inputs;};
    });

    nixosConfigurations = {
      orpheus = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {inherit inputs;};
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./host/orpheus/configuration.nix
          ];
      };
      sebastian = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.aarch64-linux;
        specialArgs = {inherit inputs;};
        modules =
          (builtins.attrValues nixosModules)
          ++ [
            ./host/sebastian/configuration.nix
          ];
      };
    };
  };
}
