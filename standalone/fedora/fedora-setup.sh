#!/usr/bin/env bash
# Fedora post-install setup: Hyprland + home-manager
# Voraussetzung: minimale Fedora-Installation, eingeloggt als briest

set -e
trap 'log_err "Fehlgeschlagen in ${FUNCNAME[0]:-main}, Zeile $LINENO (Exit-Code $?)"' ERR


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

# ─────────────────────────────────────────────────────────────────────────────

configure_dnf() {
    log_info "Configuring DNF..."

    if grep -qE "^installonly_limit\s*=\s*3" /etc/dnf/dnf.conf 2>/dev/null && \
       grep -qE "^max_parallel_downloads\s*=\s*15" /etc/dnf/dnf.conf 2>/dev/null && \
       grep -qE "^defaultyes\s*=\s*True" /etc/dnf/dnf.conf 2>/dev/null; then
        log_ok "DNF already configured. Skipping."
        return 0
    fi

    log_warn "Modifying /etc/dnf/dnf.conf — creating backup first."
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

    log_ok "DNF configured (installonly_limit=3, max_parallel_downloads=15, defaultyes=True)."
}

set_locale() {
    log_info "Setting locale to de_DE.UTF-8..."
    sudo dnf install -y glibc-langpack-de
    sudo localectl set-locale LANG=de_DE.UTF-8
    log_ok "Locale set."
}

update_system() {
    log_info "Running system update..."
    sudo dnf update -y
    log_ok "System updated."
}

enable_repos() {
    log_info "Enabling COPRs and RPM Fusion..."

    sudo dnf copr enable -y solopasha/hyprland
    log_ok "COPR solopasha/hyprland enabled."

    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    log_ok "RPM Fusion (free + nonfree) enabled."
}

install_packages() {
    log_info "Installing system packages via DNF..."

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

    log_ok "System packages installed."
}

install_noctalia() {
    log_info "Installing Noctalia shell theme via Terra repo..."
    sudo dnf install -y --nogpgcheck \
        --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
        terra-release
    sudo dnf install -y noctalia-shell
    log_ok "Noctalia installed."
}

install_brave() {
    log_info "Installing Brave browser..."
    sudo dnf config-manager addrepo \
        --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo dnf install -y brave-browser
    log_ok "Brave browser installed."
}

install_zen() {
    log_info "Installing Zen browser..."
    log_warn "This runs an install script via curl | bash."
    curl -s https://updates.zen-browser.app/install.sh | bash
    log_ok "Zen browser installed."
}

disable_selinux() {
    log_warn "Disabling SELinux (takes effect after reboot)..."
    sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    log_ok "SELinux set to disabled in /etc/selinux/config."
}

configure_sddm() {
    log_info "Configuring SDDM..."
    sudo mkdir -p /etc/sddm.conf.d
    printf '[General]\nDisplayServer=x11\n\n[Users]\nMinimumUid=1000\nMaximumUid=29999\n' \
        | sudo tee /etc/sddm.conf.d/10-display-server.conf > /dev/null
    sudo systemctl disable gdm 2>/dev/null || true
    sudo systemctl enable sddm
    sudo systemctl set-default graphical.target
    log_ok "SDDM enabled and set as default display manager."
}

install_nix() {
    log_info "Installing Nix (Determinate Systems)..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    log_ok "Nix installed."
}

apply_home_manager() {
    log_info "Applying home-manager configuration..."
    rm -f ~/.bashrc
    nix run home-manager -- switch --flake ~/nixos-config#fedora --impure
    log_ok "home-manager applied."
}

set_default_shell() {
    log_info "Setting fish as default shell..."
    chsh -s /usr/bin/fish
    log_ok "Default shell set to fish."
}

# ─────────────────────────────────────────────────────────────────────────────
# Ausführung – einzelne Schritte auskommentieren zum Testen
# ─────────────────────────────────────────────────────────────────────────────

configure_dnf
set_locale
update_system
enable_repos
install_packages
install_noctalia
install_brave
install_zen
disable_selinux
configure_sddm
install_nix
apply_home_manager
set_default_shell

log_ok "Setup abgeschlossen. Neustart empfohlen."
