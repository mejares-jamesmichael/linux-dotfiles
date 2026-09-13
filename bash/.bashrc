# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
. "$HOME/.cargo/env"

. "$HOME/.local/share/../bin/env"

# Alias
alias cls='clear'
alias lg='lazygit'
alias spotfy='spotify_player' 
alias op='opencode'
alias cdx='codex'
alias crh='crush'
alias cop='copilot'
alias af='anifetch -w 40 -H 22 -ca "--symbols block" "$HOME/Pictures/GIF/kamen-rider-zeztz-kamen-rider.gif"'

# Functions

# Bash source function
srcbsh() {
  source ~/.bashrc
}

# Yazi terminal file manager bash shell wrapper
function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# Superfile terminal file manager bash shell wrapper
s() {
    os=$(uname -s)

    # Linux
    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi

    command spf "$@"

    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

#### Search engine in the terminal (google, yt, and duckduckgo)

# --- URL encode helper ---
_urlencode() {
    if command -v jq &>/dev/null; then
        printf '%s' "$1" | jq -sRr @uri
    elif command -v python3 &>/dev/null; then
        printf '%s' "$1" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote_plus(sys.stdin.read()))"
    else
        printf '%s' "$1" | perl -MURI::Escape -ne 'print uri_escape($_)'
    fi
}

# --- Open URL in default browser ---
_open_url() {
  local url="$1"
  if command -v omarchy-launch-browser &>/dev/null; then
      omarchy-hyprland-focus-app '^chromium$' >/dev/null 2>&1 || true
      omarchy-launch-browser "$url" >/dev/null 2>&1
  else 
      command -v xdg-open &>/dev/null || {
          echo "xdg-open not found" >&2
          return 1
      }
      ( env -u BROWSER xdg-open "$1" >/dev/null 2>&1 & )
  fi
}

# --- Google search ---
ggl() {
    local lucky=0
    if [[ "$1" == "-i" || "$1" == "--lucky" ]]; then
        lucky=1
        shift
    fi

    local encoded url
    encoded=$(_urlencode "$*")

    if [ -z "$encoded" ]; then
        url="https://www.google.com"
    elif [ "$lucky" -eq 1 ]; then
        url="https://www.google.com/search?q=${encoded}&btnI=1"
    else
        url="https://www.google.com/search?q=${encoded}"
    fi

    _open_url "$url"
}

# --- DuckDuckGo search ---
ddg() {
    local encoded url
    encoded=$(_urlencode "$*")

    if [ -z "$encoded" ]; then
        url="https://duckduckgo.com"
    else
        url="https://duckduckgo.com/?q=${encoded}"
    fi

    _open_url "$url"
}

# --- Brave search ---
brv() {
    local encoded url
    encoded=$(_urlencode "$*")

    if [ -z "$encoded" ]; then
        url="https://search.brave.com/"
    else
        url="https://search.brave.com/search?q=${encoded}"
    fi

    _open_url "$url"
}

# --- YouTube search ---
yt() {
    local encoded url
    encoded=$(_urlencode "$*")

    if [ -z "$encoded" ]; then
        url="https://www.youtube.com"
    else
        url="https://www.youtube.com/results?search_query=${encoded}"
    fi

    _open_url "$url"
}
