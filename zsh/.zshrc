# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# .zshrc — fyxvoid
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ── Oh-My-Zsh ────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git sudo)
source $ZSH/oh-my-zsh.sh

# system-installed plugins (safe — skipped if not present)
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Environment ──────────────────────────────────────────────
export EDITOR="nano"
export VISUAL="nano"
export TERM="xterm-256color"
export LANG="en_US.UTF-8"
export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin:$PATH"
export GOPATH="$HOME/go"

# ── History ──────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# ── Completion ───────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Autosuggestion style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#4A7080"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ── Colors ───────────────────────────────────────────────────
[[ -x /usr/bin/dircolors ]] && eval "$(dircolors -b)"

# ── eza — ls with icons ───────────────────────────────────────
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first --color=auto'
    alias ll='eza -lah --icons --group-directories-first --git --color=auto'
    alias la='eza -a --icons --group-directories-first --color=auto'
    alias l='eza --icons --group-directories-first --color=auto'
    alias tree='eza --tree --icons --level=3 --color=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
fi

# ── bat — smart cat ───────────────────────────────────────────
if command -v batcat &>/dev/null; then
    alias cat='batcat --style=numbers,changes --theme=base16'
    alias bat='batcat'
    alias catp='batcat --style=plain --paging=never'
elif command -v bat &>/dev/null; then
    alias cat='bat --style=numbers,changes --theme=base16'
    alias catp='bat --style=plain --paging=never'
fi

# ── fzf — fuzzy finder ───────────────────────────────────────
if command -v fzf &>/dev/null; then
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && \
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && \
        source /usr/share/doc/fzf/examples/completion.zsh
    export FZF_DEFAULT_OPTS="
        --color=bg+:#243545,bg:#1C2B35,spinner:#E87DA0,hl:#5BBAD6
        --color=fg:#D8EEF8,header:#5BBAD6,info:#F0C040,pointer:#E87DA0
        --color=marker:#E87DA0,fg+:#D8EEF8,prompt:#E87DA0,hl+:#5BBAD6
        --border=sharp --prompt='  ' --pointer='>' --marker='*'
        --height=40% --layout=reverse"
    alias fcd='cd $(find . -type d | fzf)'
fi

# ── zoxide — smart cd ────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# ── fd — friendlier find (Debian/Kali ships the binary as fdfind) ──
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    alias fd='fdfind'
fi

# ── atuin — magical shell history (Ctrl+R) ───────────────────
if [[ -f "$HOME/.atuin/bin/env" ]]; then
    . "$HOME/.atuin/bin/env"
fi
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
fi

# ── Aliases — System ─────────────────────────────────────────
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias reload='source ~/.zshrc'
alias zshrc='$EDITOR ~/.zshrc'
alias cls='clear'
alias ports='ss -tulpn'
alias hosts='cat /etc/hosts'
alias path='echo $PATH | tr ":" "\n"'

# ── Aliases — Network ────────────────────────────────────────
alias myip='curl -s ifconfig.me && echo'
alias localip='ip -4 addr | awk "/inet /{print \$2}" | grep -v "127.0"'
alias tunip='ip -4 addr show tun0 2>/dev/null | awk "/inet /{print \$2}" | cut -d/ -f1'
alias sshk='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# ── Functions ────────────────────────────────────────────────

# Serve current dir over HTTP
serve() {
    command -v python3 &>/dev/null || { echo "[-] python3 not found"; return 1; }
    local port="${1:-8080}"
    echo "[+] Serving $(pwd) on :$port"
    python3 -m http.server "$port"
}

# Base64
b64e() { echo -n "$1" | base64; }
b64d() { echo -n "$1" | base64 -d; }

# URL encode
urlencode() { python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"; }

# Extract any archive
extract() {
    case "$1" in
        *.tar.gz|*.tgz)   tar xzvf "$1" ;;
        *.tar.bz2|*.tbz)  tar xjvf "$1" ;;
        *.tar.xz)         tar xJvf "$1" ;;
        *.zip)            unzip "$1"     ;;
        *.gz)             gunzip "$1"    ;;
        *.7z)             7z x "$1"      ;;
        *.rar)            unrar x "$1"   ;;
        *)                echo "unknown: $1" ;;
    esac
}

# ── NVM ──────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── Prompt (Starship — see ~/.config/starship.toml) ────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"
