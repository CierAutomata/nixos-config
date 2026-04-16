#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
FLAKE_NAME="flocke"

usage() {
  cat <<EOF
Usage: $0 [AGE_KEY_SOURCE]

Automatisiert die Schritte nach einer frischen NixOS-Installation.

AGE_KEY_SOURCE  optionaler Pfad zur privaten age-Key-Datei. Wenn kein Pfad
               angegeben ist, sucht das Skript automatisch nach einer
               key.txt oder keys.txt auf typischen USB-Mount-Pfaden.
EOF
  exit 1
}

find_key_file() {
  local paths=(/run/media/"$USER" /run/media /media/"$USER" /media /mnt)
  local result
  local found=0

  for base in "${paths[@]}"; do
    if [ -d "$base" ]; then
      while IFS= read -r -d '' file; do
        if [ "$found" -ge 1 ]; then
          echo "$file"
        else
          result="$file"
        fi
        found=$((found + 1))
      done < <(find "$base" -maxdepth 3 -type f \( -name 'key.txt' -o -name 'keys.txt' \) -print0 2>/dev/null)
    fi
  done

  if [ "$found" -eq 1 ]; then
    printf '%s' "$result"
  elif [ "$found" -gt 1 ]; then
    echo "Mehrere key/keyS.txt-Dateien gefunden:" >&2
    find /run/media/"$USER" /run/media /media/"$USER" /media /mnt -maxdepth 3 -type f \( -name 'key.txt' -o -name 'keys.txt' \) 2>/dev/null >&2
    return 1
  else
    return 2
  fi
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
fi

if [ ! -f "$REPO_ROOT/flake.nix" ]; then
  echo "Error: Dieses Skript muss im Repo-Root ausgeführt werden." >&2
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Error: nix ist nicht installiert. Bitte installiere Nix zuerst." >&2
  exit 1
fi

HARDWARE_GEN="$REPO_ROOT/hosts/default/hardware-gen.nix"

if [ -f /etc/nixos/hardware-configuration.nix ]; then
  echo "Kopiere /etc/nixos/hardware-configuration.nix nach $HARDWARE_GEN"
  sudo cp /etc/nixos/hardware-configuration.nix "$HARDWARE_GEN"
else
  echo "Warnung: /etc/nixos/hardware-configuration.nix existiert nicht." >&2
fi

KEY_SOURCE="${1:-}"
if [ -z "$KEY_SOURCE" ]; then
  echo "Suche automatisch nach key.txt auf typischen USB-Mounts..."
  if KEY_SOURCE="$(find_key_file)"; then
    echo "Gefunden: $KEY_SOURCE"
  else
    if [ $? -eq 1 ]; then
      echo "Error: Mehrere key.txt-Dateien gefunden. Bitte gib den gewünschten Pfad als Argument an." >&2
      exit 1
    fi
    echo "Warnung: Konnte keine key.txt automatisch finden." >&2
  fi
fi

if [ -n "$KEY_SOURCE" ]; then
  if [ ! -f "$KEY_SOURCE" ]; then
    echo "Error: Die angegebene Datei existiert nicht: $KEY_SOURCE" >&2
    exit 1
  fi
  mkdir -p "$HOME/.config/sops/age"
  echo "Kopiere private age-Key-Datei nach ~/.config/sops/age/keys.txt"
  cp "$KEY_SOURCE" "$HOME/.config/sops/age/keys.txt"
fi

if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
  echo "Warnung: ~/.config/sops/age/keys.txt existiert nicht." >&2
  echo "Bitte privaten age-Schlüssel hier ablegen: ~/.config/sops/age/keys.txt" >&2
fi

echo "Bitte kontrolliere in /etc/nixos/configuration.nix, dass folgende Zeile gesetzt ist:"
echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"

echo "Starte nixos-rebuild..."
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake "$REPO_ROOT#${FLAKE_NAME}"

echo "Fertig. Wenn der Rebuild erfolgreich war, kannst du das Skript künftig ohne NIX_CONFIG ausführen, sobald flakes dauerhaft aktiviert sind."