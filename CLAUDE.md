# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Deploy Commands

```bash
# Rebuild and switch immediately (--impure required for hardware-configuration.nix)
sudo nixos-rebuild switch --flake ~/nixos-config#$HOSTNAME --impure

# Rebuild on next boot
sudo nixos-rebuild boot --flake ~/nixos-config#$HOSTNAME --impure

# Test build without activating
sudo nixos-rebuild test --flake ~/nixos-config#$HOSTNAME --impure

# Check flake evaluates without errors
nix flake check

# Update flake inputs
nix flake update
```

## Architecture

### Flake Structure

`flake/hosts.nix` auto-generates a `nixosConfiguration` for every directory under `hosts/`. No manual registration is needed — adding a new directory is enough.

Shared modules loaded for all hosts are listed in `flake/hosts.nix`; host-specific settings live in `hosts/<hostname>/configuration.nix`.

### Custom Options (`modules/options.nix`)

The `myConfig.*` namespace drives conditional activation across modules:

| Option | Type | Effect |
|--------|------|--------|
| `myConfig.wm` | `"hyprland" \| "niri" \| "none"` | Loads the matching `modules/wm/*.nix` |
| `myConfig.isLaptop` | bool | Enables power-profiles-daemon, brightnessctl, lid-switch in `laptop.nix` |
| `myConfig.userName` | string | User account; drives home-manager setup |
| `myConfig.keyboard` | `"de" \| "us"` | Sets console.keyMap + xkb.layout in `core.nix` |
| `myConfig.gaming` | bool | Enables Steam/Gamescope/Java via `gaming.nix` |
| `myConfig.sddmTheme` | string | SDDM theme selection (flocke = "default", milky = "rei") |

### Module Roles

- `modules/options.nix` — declares all `myConfig` options
- `modules/core.nix` — networking, locale, shells, Pipewire+rtkit, keyboard layout, pcscd (YubiKey)
- `modules/home.nix` — user packages + dotfile symlinks via `mkOutOfStoreSymlink`; rclone bisync systemd timer
- `modules/desktop.nix` — UWSM, fonts, MIME, udisks2, polkit-gnome agent
- `modules/laptop.nix` — power-profiles-daemon (replaces TLP), 80% charge limit via udev, brightness, lid-switch
- `modules/gaming.nix` — Steam, Gamescope, Java (only when `myConfig.gaming = true`)
- `modules/boot.nix` — bootloader config
- `modules/nix-setup.nix` — nix settings (substituters, gc, etc.)
- `modules/tools.nix` — common CLI tools
- `modules/home-manager-setup.nix` — home-manager integration
- `modules/wm/hyprland.nix` / `niri.nix` — compositor, portals, polkit

### Hosts

- `flocke` — Laptop, `isLaptop=true`, `keyboard="us"`, `wm="hyprland"`
- `milky` — Desktop, `gaming=true`, `keyboard="de"`, NVIDIA (`modesetting` + `powerManagement` enabled)
- `template` — Kopiervorlage für neue Hosts; alle Optionen vorhanden, optionale auskommentiert

### Deprecated

- `bootstrap.sh` — nicht mehr relevant, wird bald gelöscht oder komplett neu geschrieben. Nicht verwenden.

### Dotfiles

`dotfiles/` is symlinked live into `~/.config/` using `config.lib.file.mkOutOfStoreSymlink`. Edits take effect immediately without a rebuild. Per-host overrides live in `dotfiles/<app>/hosts/<hostname>.*` and are sourced from the main config file.

### Hardware Configuration

`/etc/nixos/hardware-configuration.nix` is sourced directly (not committed); this is why `--impure` is required for all rebuilds. Persistent mount points and host-specific hardware settings are in `hosts/<hostname>/hardware.nix`.
