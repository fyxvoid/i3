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
    i3status

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

    # Modern CLI
    eza
    bat
    zoxide
    fzf
    ripgrep
    fd-find

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
    dnsutils
    netcat-openbsd

    # Utilities
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
section "Starship prompt"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ! command -v starship &>/dev/null; then
    info "Installing starship..."
    mkdir -p "$USER_HOME/.local/bin"
    if curl -fsSL https://starship.rs/install.sh | sh -s -- -y --bin-dir "$USER_HOME/.local/bin"; then
        ok "starship installed to ~/.local/bin"
    else
        warn "starship install failed — continuing. Install manually later."
    fi
else
    ok "starship already present — skipping"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Atuin (shell history)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ ! -x "$USER_HOME/.atuin/bin/atuin" ]]; then
    info "Installing atuin..."
    if curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh; then
        ok "atuin installed to ~/.atuin/bin"
    else
        warn "atuin install failed — continuing. Install manually later."
    fi
else
    ok "atuin already present — skipping"
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
    "$USER_HOME/.config/alacritty" \
    "$USER_HOME/.config/picom" \
    "$USER_HOME/.config/dunst/scripts" \
    "$USER_HOME/Pictures/Screenshots"

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
_copy "i3/i3status.conf"                  "$USER_HOME/.config/i3/i3status.conf"
_copy "alacritty/alacritty.toml"          "$USER_HOME/.config/alacritty/alacritty.toml"
_copy "picom/picom.conf"                  "$USER_HOME/.config/picom/picom.conf"
_copy "zsh/.zshrc"                        "$USER_HOME/.zshrc"
_copy "starship/starship.toml"            "$USER_HOME/.config/starship.toml"
_copy "dunst/dunstrc"                     "$USER_HOME/.config/dunst/dunstrc"
_copy "dunst/scripts/osd-volume.sh"       "$USER_HOME/.config/dunst/scripts/osd-volume.sh"
_copy "dunst/scripts/osd-brightness.sh"   "$USER_HOME/.config/dunst/scripts/osd-brightness.sh"
chmod +x "$USER_HOME/.config/dunst/scripts/"*.sh

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
echo -e "  3. Launcher: ${B}Mod+D${N}  |  Terminal: ${B}Mod+Enter${N}"
echo ""
