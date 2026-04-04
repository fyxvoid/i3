#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# install.sh — fyxvoid dotfiles setup
# Supports: Debian, Ubuntu, Kali, Parrot and derivatives
# Usage: bash install.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_HOME="$HOME"

# ── Colors ───────────────────────────────────────────────────
G='\033[0;32m'
B='\033[0;34m'
Y='\033[0;33m'
R='\033[0;31m'
N='\033[0m'

info()    { echo -e "${B}[*]${N} $*"; }
ok()      { echo -e "${G}[+]${N} $*"; }
warn()    { echo -e "${Y}[!]${N} $*"; }
die()     { echo -e "${R}[x]${N} $*" >&2; exit 1; }
section() { echo -e "\n${G}━━━ $* ━━━${N}"; }

# ── Root check ───────────────────────────────────────────────
[[ $EUID -eq 0 ]] && die "Do not run as root. Run as your normal user."

# ── Debian/Ubuntu check ──────────────────────────────────────
command -v apt &>/dev/null || die "This script requires apt (Debian/Ubuntu/Kali/Parrot)."

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "APT update"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sudo apt update -qq || die "apt update failed — check your internet connection."

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "APT packages"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PKGS=(
    # WM + compositor + display
    i3
    i3lock
    picom
    feh
    xorg
    x11-xserver-utils
    dex
    xss-lock
    arandr

    # Bar
    polybar

    # Terminal
    alacritty

    # Launcher
    dmenu
    j4-dmenu-desktop

    # Notifications
    dunst

    # Shell
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Fonts
    fonts-jetbrains-mono

    # Modern CLI
    eza
    bat
    zoxide
    fzf

    # File manager + apps
    thunar
    firefox-esr
    flameshot

    # Audio + brightness
    pulseaudio
    pavucontrol
    brightnessctl

    # Network
    network-manager
    network-manager-gnome
    curl
    wget
    git
    openvpn
    wireguard

    # Pentest — recon
    nmap
    gobuster
    nikto
    whatweb
    ffuf
    dnsutils

    # Pentest — web
    feroxbuster

    # Pentest — password
    hydra
    john
    hashcat

    # Pentest — misc
    socat
    tmux
    neovim
    xclip
    python3
    python3-pip
    unzip
    p7zip-full
    unrar
)

# netcat: prefer traditional (supports -e flag for shells)
if apt-cache show netcat-traditional &>/dev/null 2>&1; then
    PKGS+=(netcat-traditional)
else
    PKGS+=(netcat-openbsd)
fi

# wordlists (available on Kali/Parrot, may not exist on vanilla Debian/Ubuntu)
if apt-cache show wordlists &>/dev/null 2>&1; then
    PKGS+=(wordlists)
fi

# seclists (Kali only, large package ~900MB — optional)
# Uncomment to include:
# if apt-cache show seclists &>/dev/null 2>&1; then PKGS+=(seclists); fi

info "Installing ${#PKGS[@]} packages..."
sudo apt install -y "${PKGS[@]}" || die "Package installation failed."
ok "Packages installed"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Oh-My-Zsh"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ ! -d "$USER_HOME/.oh-my-zsh" ]]; then
    info "Installing oh-my-zsh..."
    if RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
        ok "oh-my-zsh installed"
    else
        warn "oh-my-zsh install failed — continuing. Install manually later."
    fi
else
    ok "oh-my-zsh already present — skipping"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Default shell → zsh"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
    info "Setting zsh as default shell..."
    sudo chsh -s "$ZSH_BIN" "$USER" || warn "chsh failed — run manually: chsh -s $ZSH_BIN"
    ok "Default shell set to zsh"
else
    ok "zsh already default shell"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Directories"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mkdir -p \
    "$USER_HOME/.config/i3/config.d" \
    "$USER_HOME/.config/polybar/scripts" \
    "$USER_HOME/.config/alacritty" \
    "$USER_HOME/.config/picom" \
    "$USER_HOME/.config/dunst" \
    "$USER_HOME/.config/pentest" \
    "$USER_HOME/Pictures/Screenshots" \
    "$USER_HOME/htb" \
    "$USER_HOME/tools" \
    "$USER_HOME/vpn"

ok "Directories created"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Dotfiles"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_copy() {
    local src="$DOTFILES_DIR/$1"
    local dst="$2"
    if [[ -f "$src" ]]; then
        cp "$src" "$dst"
        ok "$dst"
    else
        warn "missing source: $src — skipping"
    fi
}

_copy "i3/config"                         "$USER_HOME/.config/i3/config"
_copy "polybar/config.ini"                "$USER_HOME/.config/polybar/config.ini"
_copy "polybar/launch.sh"                 "$USER_HOME/.config/polybar/launch.sh"
_copy "polybar/scripts/vpn-status.sh"     "$USER_HOME/.config/polybar/scripts/vpn-status.sh"
_copy "polybar/scripts/htb-status.sh"     "$USER_HOME/.config/polybar/scripts/htb-status.sh"
_copy "polybar/scripts/ip-local.sh"       "$USER_HOME/.config/polybar/scripts/ip-local.sh"
_copy "polybar/scripts/workspaces.sh"     "$USER_HOME/.config/polybar/scripts/workspaces.sh"
_copy "alacritty/alacritty.toml"          "$USER_HOME/.config/alacritty/alacritty.toml"
_copy "picom/picom.conf"                  "$USER_HOME/.config/picom/picom.conf"
_copy "zsh/.zshrc"                        "$USER_HOME/.zshrc"

# Fix polybar battery/thermal — add system-specific note
if [[ -f "$USER_HOME/.config/polybar/config.ini" ]]; then
    BAT=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE "^BAT" | head -1)
    ADP=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE "^(AC|ADP|ACAD)" | head -1)
    if [[ -n "$BAT" && -n "$ADP" ]]; then
        sed -i "s/^battery\s*=.*/battery       = $BAT/" "$USER_HOME/.config/polybar/config.ini"
        sed -i "s/^adapter\s*=.*/adapter       = $ADP/" "$USER_HOME/.config/polybar/config.ini"
        ok "Polybar battery auto-configured: $BAT / $ADP"
    else
        warn "No battery found — polybar battery module will be inactive"
    fi
fi

# Permissions
chmod +x "$USER_HOME/.config/polybar/launch.sh"
chmod +x "$USER_HOME/.config/polybar/scripts/"*.sh

ok "Dotfiles deployed"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Fonts (local — no internet needed)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FONT_DIR="$USER_HOME/.fonts"
mkdir -p "$FONT_DIR"

if [[ -d "$DOTFILES_DIR/fonts" ]] && [[ -n "$(ls "$DOTFILES_DIR/fonts/"*.ttf 2>/dev/null)" ]]; then
    info "Installing fonts from dotfiles/fonts/..."
    cp "$DOTFILES_DIR/fonts/"*.ttf "$FONT_DIR/"
    fc-cache -f "$FONT_DIR"
    ok "Fonts installed: $(ls "$DOTFILES_DIR/fonts/"*.ttf | wc -l) files"
else
    warn "No fonts found in dotfiles/fonts/ — bar icons may not render"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Wallpaper"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PICS="$USER_HOME/Pictures"
mkdir -p "$PICS"

if [[ -d "$DOTFILES_DIR/wallpapers" ]] && [[ -n "$(ls "$DOTFILES_DIR/wallpapers/" 2>/dev/null)" ]]; then
    info "Copying wallpapers from dotfiles/wallpapers/..."
    cp "$DOTFILES_DIR/wallpapers/"* "$PICS/"
    ok "Wallpapers copied to $PICS"
else
    warn "No wallpapers found in dotfiles/wallpapers/"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Done"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "  ${G}All set.${N} Next steps:"
echo -e "  1. Log out and select ${B}i3${N} from your display manager"
echo -e "     Or run: ${B}startx /usr/bin/i3${N}"
echo -e "  2. Wallpaper: drop any image into ${B}~/Pictures/${N}"
echo -e "  3. VPN config: place your .ovpn file in ${B}~/vpn/${N}"
echo -e "  4. Launcher: ${B}Mod+D${N}  |  Terminal: ${B}Mod+Enter${N}"
echo -e "  5. Pentest mode: ${B}Mod+P${N}"
echo ""
