# kanata module (Darwin)

A nix-darwin module providing `services.kanata` — runs kanata as a root launchd daemon with Karabiner DriverKit support.

On NixOS, use the upstream `services.kanata` module from nixpkgs instead.

## Usage

```nix
# configuration.nix (nix-darwin)
{
  imports = [ ../../modules/kanata/module.nix ];

  services.kanata = {
    enable = true;
    configFile = "/Users/yourusername/.config/kanata/default.kbd";
  };
}
```

## What it does

- Adds `kanata` to system packages
- Creates a root `kanata` launchd daemon (`org.nixos.kanata`) with KeepAlive
- Optionally manages Karabiner DriverKit launchd daemons (on by default)
- Provides a `setup-karabiner-driverkit` helper script for one-time DriverKit installation

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable the module |
| `package` | package | `pkgs.kanata` | kanata package |
| `configFile` | path | — | Path to .kbd config file |
| `port` | nullOr port | `null` | TCP server port (null = disabled) |
| `extraArgs` | listOf str | `[]` | Extra CLI arguments |
| `karabinerDriverKit.enable` | bool | `true` | Manage DriverKit launchd daemons |
| `karabinerDriverKit.version` | string | `"5.0.0"` | DriverKit version for setup script |

## macOS setup

After the first `darwin-rebuild switch`, grant kanata **Accessibility** and **Input Monitoring** permissions in System Settings.

If Karabiner DriverKit is not yet installed, the activation script will run `setup-karabiner-driverkit` interactively to download and install it.
