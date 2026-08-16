# i3

A dark-themed i3wm dotfiles setup for Debian-based distros (Debian, Ubuntu, Kali, Parrot). One script installs everything and deploys the configs; the result is a minimal, keyboard-driven desktop with a modern CLI toolchain wired into the shell.

## Contents

| Path | What it configures |
|---|---|
| `i3/config` | Window manager: keybindings, workspaces, colors, bar |
| `i3/i3status.conf` | Status bar (CPU, RAM, disk, network, battery, load, clock) |
| `alacritty/alacritty.toml` | Terminal emulator theme and behavior |
| `picom/picom.conf` | Compositor: shadows, fading, transparency, blur |
| `dunst/dunstrc` | Notification daemon styling |
| `dunst/scripts/` | Volume/brightness OSD scripts (called from media keys) |
| `starship/starship.toml` | Shell prompt |
| `zsh/.zshrc` | Shell config, aliases, functions, tool integrations |
| `fonts/` | JetBrainsMono Nerd Font + Noto Color Emoji |
| `wallpapers/` | Wallpaper images |
| `install.sh` | Installs packages and deploys every config above |

## Install

```bash
git clone git@github.com:fyxvoid/i3.git
cd i3
bash install.sh
```

The script (requires `sudo`, run as a normal user — not root):

1. Installs everything via `apt`: i3, picom, alacritty, dunst, zsh + plugins, the CLI toolchain below, and general desktop utilities (file manager, screenshot tool, VPN clients, etc.)
2. Installs [oh-my-zsh](https://ohmyz.sh/), [starship](https://starship.rs/), and [atuin](https://atuin.sh/) (not packaged in apt)
3. Sets zsh as your default shell
4. Copies every config into `~/.config/`, `~/.zshrc`, and `~/.fonts/`
5. Copies the bundled wallpaper into `~/Pictures/`

After it finishes, log out and select **i3** from your display manager, or run `startx /usr/bin/i3`.

Re-running `install.sh` is safe — it skips anything already installed and just re-deploys the dotfiles.

## Shell toolchain

`zsh/.zshrc` wires up a modern CLI replacement for the usual Unix tools, all with fallbacks if a tool isn't present:

| Tool | Replaces | Notes |
|---|---|---|
| [atuin](https://atuin.sh/) | shell history | `Ctrl+R` — fuzzy search across all sessions with exit code/timestamp |
| [fzf](https://github.com/junegunn/fzf) | — | fuzzy finder, also improves `Ctrl+R` / `Ctrl+T` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | `z <partial-name>` jumps to frecent directories |
| [eza](https://github.com/eza-community/eza) | `ls` | icons, git status, `ll`/`la`/`tree` aliases |
| [bat](https://github.com/sharkdp/bat) | `cat` | syntax highlighting (aliased from `batcat` on Debian/Kali) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `grep` | faster, respects `.gitignore` |
| [fd-find](https://github.com/sharkdp/fd) (`fd`) | `find` | faster, friendlier syntax (aliased from `fdfind` on Debian/Kali) |
| `zsh-autosuggestions` | — | greys out a suggested command as you type |
| `zsh-syntax-highlighting` | — | highlights valid/invalid commands live |

Useful functions defined in `.zshrc`: `serve [port]` (HTTP server in the current dir), `extract <archive>` (unpacks tar/zip/7z/rar/gz), `b64e`/`b64d`, `urlencode`.

## Keybindings

Mod key is **Super** (`$mod` = `Mod4`).

| Binding | Action |
|---|---|
| `Mod+Return` | Terminal (Alacritty) |
| `Mod+Shift+Return` | Floating terminal |
| `Mod+d` | App launcher (j4-dmenu-desktop) |
| `Mod+Shift+d` | dmenu_run |
| `Mod+b` | Firefox |
| `Mod+Shift+f` | File manager (Thunar) |
| `Print` / `Mod+Print` | Screenshot (region / full, via flameshot) |
| `Mod+h/j/k/l` or arrows | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+x` / `Mod+v` | Split horizontal / vertical |
| `Mod+f` | Fullscreen toggle |
| `Mod+s` / `Mod+w` / `Mod+e` | Stacking / tabbed / toggle split layout |
| `Mod+Shift+space` | Floating toggle |
| `Mod+1..0` | Switch workspace |
| `Mod+Shift+1..0` | Move window to workspace |
| `Mod+bracketleft/right` | Previous / next workspace |
| `Mod+r` | Resize mode |
| `Mod+Shift+x` | Lock screen |
| `Mod+Shift+c` / `Mod+Shift+r` | Reload / restart i3 |
| `Mod+Shift+e` | Exit menu (logout/reboot/shutdown) |
| Media keys | Volume, mic mute, brightness (OSD via dunst) |

Workspaces are numbered 1–10; Firefox/Chromium auto-assign to workspace 2, your code editor to 3, Thunar to 4, and VM managers (VirtualBox/VMware/virt-manager) to 9.

## Theme

Dark background with a grass-green accent (`#7ed321`) used for the focused workspace, and the CPU/RAM/disk/wifi/battery/load/time bar tags. Full palette is defined at the top of `i3/config` (`$bg`, `$fg`, `$cyan`, `$green`, `$red`, `$yellow`, `$magenta`, `$blue`, `$orange`) and mirrored in `alacritty.toml`, `picom.conf`, `dunst/dunstrc`, and `starship.toml`.

To swap the wallpaper, drop an image in `~/Pictures/` and update `$wallpaper` (feh needs a `.jpg`/`.png`) and `$lockimg` (i3lock needs a Cairo-readable PNG) at the top of `i3/config`.

## Requirements

- A Debian-based distro with `apt` (Debian, Ubuntu, Kali, Parrot, or a derivative)
- `sudo` access
- An internet connection (for `apt` packages plus the oh-my-zsh/starship/atuin installers)

Some packages (`eza`, `zoxide`, `ripgrep`, `fd-find`) may be missing on older LTS releases — if `install.sh` fails on a package name, remove it from the `PKGS` array in `install.sh` and install it manually afterward.
