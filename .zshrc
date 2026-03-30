# ─── Environment variables ────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export GPG_TTY=$(tty)

# ─── Platform detection ──────────────────────────────────────────────
OS="$(uname -s)"

# ─── PATH ─────────────────────────────────────────────────────────────
export PATH="$PATH:$HOME/.local/bin"

if [[ "$OS" == "Darwin" ]]; then
  export HOMEBREW_NO_AUTO_UPDATE=1
  export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi

# ─── Terminal fixes ───────────────────────────────────────────────────
# Fall back to xterm-256color if terminfo not available (e.g. SSH with Ghostty)
if ! infocmp "$TERM" &>/dev/null 2>&1; then
  export TERM=xterm-256color
fi

# ─── Tool initialisation ─────────────────────────────────────────────
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

command -v gpgconf &>/dev/null && gpgconf --launch gpg-agent

# Nix home-manager PATH (Linux — on macOS, nix-darwin sets this via /etc/zshenv)
if [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Atuin shell history
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
command -v atuin &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# fzf fuzzy completion (no keybindings — atuin handles ^R)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude __pycache__ --exclude .venv'

# Ghostty shell integration
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# ─── Key bindings ─────────────────────────────────────────────────────
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

# Edit command line in $EDITOR with Ctrl-X Ctrl-E
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ─── Aliases ──────────────────────────────────────────────────────────
# Editors & tools
alias vim="nvim"
alias n="nvim"
alias ls="eza -l"
alias lg="lazygit"
alias lsql="lazysql"

# Git
alias dot='git --git-dir=$HOME/git/dotfiles --work-tree=$HOME'
alias dotlg='lazygit -g $HOME/git/dotfiles -w $HOME'
alias pob='push_one_by_one'

# Nix
if [[ "$OS" == "Darwin" ]]; then
  case "$(scutil --get LocalHostName 2>/dev/null)" in
    macbook-air) _nix_host="work-mac" ;;
    *)           _nix_host="personal-mac" ;;
  esac
  alias drs="sudo darwin-rebuild switch --flake ~/.config/nix#$_nix_host"
else
  alias hms='home-manager switch --flake ~/.config/nix'
fi
alias nfu='nix flake update --flake ~/.config/nix'

# Python / linting
alias f=".venv/bin/ruff format . && .venv/bin/ruff check . --fix"

# Image helpers
alias tojpg='img tojpg'
alias pad='img pad'

# SSH (only on Mac — you're already on the NUC if on Linux)
[[ "$OS" == "Darwin" ]] && alias nuc="ssh 192.168.88.200"

# ─── Functions ────────────────────────────────────────────────────────
# Push commits one-by-one to trigger CI for each
push_one_by_one() {
    local target_branch=${1:-$(git rev-parse --abbrev-ref HEAD)}
    local comparison_branch=${2:-"origin/staging"}
    echo "Pushing commits one by one from $target_branch"
    git log "$comparison_branch..$target_branch" --reverse --pretty="format:%h" | \
        xargs -I{} git push origin {}:"$target_branch" -f
}

# Cross-platform clipboard
if [[ "$OS" == "Darwin" ]]; then
  _clip_copy() { pbcopy; }
else
  _clip_copy() { xclip -selection clipboard; }
fi

# Copy file contents to clipboard
clip() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: clip <file...>" >&2
    return 1
  fi
  cat "$@" | _clip_copy
  echo "Copied $* to clipboard"
}

# Pick a file with fzf and copy its contents
clipf() { cat "$(fzf)" | _clip_copy; }

# Show current Ghostty theme
theme() {
  ghostty +show-config | sed -n 's/^theme = //p' | head -n1
}

# ─── Ghostty theme widgets (bound to custom CSI sequences) ───────────
theme-random-widget() {
  zle -I
  ~/.config/ghostty/bin/theme-random >/dev/null 2>&1
  zle reset-prompt
}
zle -N theme-random-widget
bindkey '\e[999~' theme-random-widget

theme-reset-widget() {
  zle -I
  ~/.config/ghostty/bin/theme-reset >/dev/null 2>&1
  zle reset-prompt
}
zle -N theme-reset-widget
bindkey '\e[998~' theme-reset-widget
