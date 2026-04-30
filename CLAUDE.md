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
| `myConfig.sddmTheme` | string | SDDM theme selection (itnb-b2954j3 = "default", milky = "rei") |

### Module Roles

- `modules/options.nix` — declares all `myConfig` options
- `modules/core.nix` — networking, locale, shells, Pipewire+rtkit, keyboard layout, pcscd (YubiKey); sets `QEMU_AUDIO_DRV=pipewire`
- `modules/home.nix` — user packages (inkl. rustc/cargo) + dotfile symlinks via `mkOutOfStoreSymlink`; rclone bisync systemd timer
- `modules/desktop.nix` — UWSM, fonts, MIME, udisks2, polkit-gnome agent
- `modules/laptop.nix` — power-profiles-daemon (replaces TLP), 80% charge limit via udev, brightness, lid-switch
- `modules/gaming.nix` — Steam, Gamescope, Java (only when `myConfig.gaming = true`)
- `modules/boot.nix` — bootloader config
- `modules/nix-setup.nix` — nix settings (substituters, gc, etc.)
- `modules/tools.nix` — common CLI tools
- `modules/home-manager-setup.nix` — home-manager integration
- `modules/silent-sddm.nix` — SDDM via `silentSDDM` flake input; theme via `myConfig.sddmTheme`
- `modules/sops.nix` — sops-nix mit age+YubiKey; verwaltet `user-password` und `root-password` aus `secrets/secrets.yaml`
- `modules/wm/hyprland.nix` / `niri.nix` — compositor, portals, polkit

### Hosts

- `itnb-b2954j3` — Laptop, `isLaptop=true`, `keyboard="us"`, `wm="hyprland"`, `userName="briest"`; libvirtd + QEMU/OVMF/virt-manager/looking-glass-client; OVMF unter stabilen Pfaden `/etc/ovmf/`
- `milky` — Desktop, `gaming=true`, `keyboard="de"`, `wm="niri"`, `userName="cier"`, NVIDIA (`modesetting` + `powerManagement` enabled); libvirtd aktiviert mit QEMU/OVMF/virt-manager/looking-glass-client; OVMF unter stabilen Pfaden `/etc/ovmf/`
- `template` — Kopiervorlage für neue Hosts; alle Optionen vorhanden, optionale auskommentiert

### Custom Packages

`packages/` enthält selbst gepflegte Nix-Derivationen:

- `packages/vm-curator/` — TUI-VM-Manager; fetcht von `github:mroboff/vm-curator` und wendet `nixos-fixes.patch` an (PipeWire-Audio, chmod OVMF_VARS, NixOS-Pfade). Update mit `./packages/vm-curator/update.sh [version]`.

### Deprecated

- `bootstrap.sh` — nicht mehr relevant, wird bald gelöscht oder komplett neu geschrieben. Nicht verwenden.

### Standalone (Nicht-NixOS)

`standalone/` enthält home-manager-Konfigurationen für Nicht-NixOS-Systeme.

- `standalone/fedora/` — home-manager für Fedora, User `briest`; dotfile-Symlinks (alacritty, fish, hypr, kitty, niri, nvim …), yazi, kitty-yazi Desktop-Eintrag, git-Konfiguration

### Dotfiles

`dotfiles/` is symlinked live into `~/.config/` using `config.lib.file.mkOutOfStoreSymlink`. Edits take effect immediately without a rebuild. Per-host overrides live in `dotfiles/<app>/hosts/<hostname>.*` and are sourced from the main config file.

### Hardware Configuration

`/etc/nixos/hardware-configuration.nix` is sourced directly (not committed); this is why `--impure` is required for all rebuilds. Persistent mount points and host-specific hardware settings are in `hosts/<hostname>/hardware.nix`.
