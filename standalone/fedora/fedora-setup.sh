#!/usr/bin/env bash
# Fedora post-install setup: Hyprland + home-manager
# Voraussetzung: minimale Fedora-Installation, eingeloggt als briest
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()   { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $*"; }

preflight_checks() {
    log_info "Running preflight checks..."

    if [[ "$(id -u)" -eq 0 ]]; then
        log_err "Do not run this script as root. Run as a regular user with sudo access."
        exit 1
    fi

    if ! sudo -n true 2>/dev/null; then
        log_warn "This script requires sudo privileges. You will be prompted for your password."
    fi

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "${ID:-}" != "fedora" ]]; then
            log_err "This script is designed for Fedora. Detected: ${ID:-unknown}"
            exit 1
        fi
        log_ok "Detected Fedora ${VERSION_ID:-unknown}"
    else
        log_err "Cannot detect operating system."
        exit 1
    fi

    if [[ ! -d "${SCRIPT_DIR}/.config" ]]; then
        log_err "Expected ${SCRIPT_DIR}/.config/ not found."
        log_err "Dotfiles must use the layout: ~/dotfiles/.config/<app>/"
        exit 1
    fi

    log_ok "Preflight checks passed."
}

configure_dnf() {
    log_info "Configuring DNF..."

    if grep -q "^installonly_limit=3" /etc/dnf/dnf.conf 2>/dev/null && \
       grep -q "^max_parallel_downloads=15" /etc/dnf/dnf.conf 2>/dev/null && \
       grep -q "^defaultyes=True" /etc/dnf/dnf.conf 2>/dev/null; then
        log_ok "DNF already configured. Skipping."
        return 0
    fi

    sudo cp /etc/dnf/dnf.conf "/etc/dnf/dnf.conf.bak.$(date +%Y%m%d%H%M%S)"

    sudo python3 - <<'PYEOF'
import configparser

conf_path = "/etc/dnf/dnf.conf"

config = configparser.ConfigParser()
config.optionxform = str
config.read(conf_path)

if not config.has_section("main"):
    config.add_section("main")

updates = {
    "installonly_limit": "3",
    "max_parallel_downloads": "15",
    "defaultyes": "True"
}

for key, value in updates.items():
    config.set("main", key, value)

with open(conf_path, "w") as f:
    config.write(f)
PYEOF

    log_ok "DNF configuration updated."
}
configure_dnf
set -e

# --- Locale setzen ---
sudo dnf install -y glibc-langpack-de
sudo localectl set-locale LANG=de_DE.UTF-8

# --- System-Updates ---
sudo dnf update -y

# --- COPRs aktivieren ---
# uwsm ist über solopasha/hyprland verfügbar
sudo dnf copr enable -y solopasha/hyprland

# --- RPM-Fusion aktivieren
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# --- Systemweite Pakete per DNF ---
# hyprland ist seit Fedora 40 in den offiziellen Repos verfügbar
sudo dnf install -y \
    uwsm \
    gnome-keyring \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    mesa-dri-drivers \
    mesa-vulkan-drivers \
    xfce-polkit \
    sddm \
    fish \
    git \
    udiskie \
    xdg-utils \
    gvfs \
    nautilus \
    remmina \
    remmina-plugins-rdp \
    freerdp \
    xorg-x11-server-Xorg \
    xorg-x11-server-Xwayland \
    qt5-qtwayland \
    qt6-qtwayland \
    sddm-breeze \
    neovim \
    gh \
    alacritty \
    kitty \
    rclone \
    cava \
    fastfetch \
    btop \
    cmatrix \
    sox \
    firefox \
    jetbrains-mono-fonts \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    wl-clipboard \
    grim \
    slurp \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    network-manager-applet \
    playerctl \
    pavucontrol \
    blueman \
	starship \
	luarocks \
	adw-gtk3-theme \
	nwg-look \
	tar \
	codium

# --- Noctalia via Terra Repo ---
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf install -y noctalia-shell

# --- Brave Browser ---
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install -y brave-browser

# --- Zen Browser
curl -s https://updates.zen-browser.app/install.sh | bash

# --- SELinux deaktivieren ---
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# --- SDDM aktivieren + auf Xorg setzen ---
sudo mkdir -p /etc/sddm.conf.d
printf '[General]\nDisplayServer=x11\n\n[Users]\nMinimumUid=1000\nMaximumUid=29999\n' | sudo tee /etc/sddm.conf.d/10-display-server.conf
sudo systemctl disable gdm 2>/dev/null || true
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

# --- Nix installieren (Determinate Systems) ---
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# --- nixos-config klonen ---
git clone https://github.com/CierAutomata/nixos-config.git ~/nixos-config

# --- home-manager anwenden ---
rm -f ~/.bashrc
nix run home-manager -- switch --flake ~/nixos-config#fedora --impure

# --- fish als Standard-Shell setzen ---
chsh -s /usr/bin/fish

echo "Fertig. Neustart empfohlen."
