{ config, lib, pkgs, ... }:

let
  cfg = config.services.kanata;
  inherit (lib) mkEnableOption mkOption mkIf mkMerge types literalExpression;

  # Karabiner DriverKit paths (installed by the .pkg)
  karabinerBase = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice";
  vhidManagerApp = "/Applications/.Karabiner-VirtualHIDDevice-Manager.app";
  vhidDaemonBin = "${karabinerBase}/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
  vhidManagerBin = "${vhidManagerApp}/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";

  setupScript = pkgs.writeShellScriptBin "setup-karabiner-driverkit" ''
    set -euo pipefail
    VERSION="${cfg.karabinerDriverKit.version}"
    PKG_NAME="Karabiner-DriverKit-VirtualHIDDevice-''${VERSION}.pkg"
    DOWNLOAD_URL="https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v''${VERSION}/''${PKG_NAME}"

    echo "==> Checking for existing Karabiner DriverKit installation..."
    if [ -d "${vhidManagerApp}" ]; then
      INSTALLED_VERSION=$(defaults read "${vhidManagerApp}/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
      echo "    Found existing installation (version ''${INSTALLED_VERSION})"
      read -rp "    Reinstall? [y/N] " answer
      if [[ "''${answer}" != [yY] ]]; then
        echo "    Skipping installation."
        exit 0
      fi
    fi

    echo "==> Downloading Karabiner-DriverKit-VirtualHIDDevice v''${VERSION}..."
    TMPFILE=$(mktemp /tmp/karabiner-driverkit-XXXXXX.pkg)
    trap 'rm -f "''${TMPFILE}"' EXIT
    ${pkgs.curl}/bin/curl -fSL -o "''${TMPFILE}" "''${DOWNLOAD_URL}"

    echo "==> Installing .pkg (requires sudo)..."
    sudo installer -pkg "''${TMPFILE}" -target /

    echo "==> Activating DriverKit system extension..."
    "${vhidManagerBin}" activate

    echo ""
    echo "==> IMPORTANT: You must approve the system extension in System Settings."
    echo "    Go to: System Settings → General → Login Items & Extensions"
    echo "    Look for 'Karabiner' under 'Driver Extensions' and enable it."
    echo ""
    read -rp "Press Enter to open System Settings..."
    open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
    read -rp "Press Enter once you have approved the extension..."

    echo "==> Done! The launchd services are managed by nix-darwin."
    echo "    Run 'darwin-rebuild switch' if you haven't already."
  '';
in
{
  options.services.kanata = {
    enable = mkEnableOption "kanata keyboard remapper (Darwin launchd daemon)";

    package = mkOption {
      type = types.package;
      default = pkgs.kanata;
      defaultText = literalExpression "pkgs.kanata";
      description = "The kanata package to use.";
    };

    configFile = mkOption {
      type = types.path;
      description = "Path to the kanata configuration file (.kbd).";
    };

    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "TCP port for kanata's server. null disables it.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra command-line arguments passed to kanata.";
    };

    karabinerDriverKit = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to set up Karabiner DriverKit launchd daemons.";
      };

      version = mkOption {
        type = types.str;
        default = "6.10.0";
        description = "Version of Karabiner-DriverKit-VirtualHIDDevice for the setup script.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # ── Common ───────────────────────────────────────────────────────────
    {
      environment.systemPackages = [ cfg.package ];
    }

    # ── kanata launchd daemon ────────────────────────────────────────────
    {
      launchd.daemons.kanata = {
        serviceConfig = {
          Label = "org.nixos.kanata";
          ProgramArguments =
            [ "${cfg.package}/bin/kanata" "-c" (toString cfg.configFile) ]
            ++ lib.optionals (cfg.port != null) [ "--port" (toString cfg.port) ]
            ++ cfg.extraArgs;
          RunAtLoad = true;
          KeepAlive = true;
          SessionCreate = true;
          ProcessType = "Interactive";
          StandardErrorPath = "/tmp/kanata.stderr.log";
          StandardOutPath = "/tmp/kanata.stdout.log";
        };
      };
    }

    # ── Karabiner DriverKit ──────────────────────────────────────────────
    (mkIf cfg.karabinerDriverKit.enable {
      environment.systemPackages = [ setupScript ];

      system.activationScripts.postActivation.text = ''
        if [ -d "${karabinerBase}" ] && [ -x "${vhidManagerBin}" ]; then
          echo "Activating Karabiner DriverKit extension..."
          "${vhidManagerBin}" activate 2>/dev/null || true
        else
          echo "Karabiner DriverKit not installed, running setup..."
          ${setupScript}/bin/setup-karabiner-driverkit
        fi
      '';

      launchd.daemons.karabiner-vhid-manager = {
        serviceConfig = {
          Label = "org.nixos.karabiner-vhid-manager";
          ProgramArguments = [
            "${vhidManagerBin}"
            "activate"
          ];
          RunAtLoad = true;
        };
      };

      launchd.daemons.karabiner-vhid-daemon = {
        serviceConfig = {
          Label = "org.nixos.karabiner-vhid-daemon";
          ProgramArguments = [
            "${vhidDaemonBin}"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          ProcessType = "Interactive";
        };
      };
    })
  ]);
}
