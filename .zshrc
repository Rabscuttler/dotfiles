# ─── Environment variables ────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export GPG_TTY=$(tty)
export HOMEBREW_NO_AUTO_UPDATE=1

# ─── PATH ─────────────────────────────────────────────────────────────
export PATH="/Users/laurence/.antigravity/antigravity/bin:$PATH"  # Antigravity
export PATH="$PATH:/Users/laurence/.local/bin"

# ─── Tool initialisation ─────────────────────────────────────────────
. "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

gpgconf --launch gpg-agent

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# Atuin shell history
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"

# fzf key bindings and fuzzy completion
source <(fzf --zsh)
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
alias lgdot='lazygit -g $HOME/git/dotfiles -w $HOME'
alias pob='push_one_by_one'

# Python / linting
alias f=".venv/bin/ruff format . && .venv/bin/ruff check . --fix"

# Image helpers
alias tojpg='img tojpg'
alias pad='img pad'

# SSH
alias nuc="ssh 192.168.88.200"

# ─── Functions ────────────────────────────────────────────────────────
# Push commits one-by-one to trigger CI for each
push_one_by_one() {
    local target_branch=${1:-$(git rev-parse --abbrev-ref HEAD)}
    local comparison_branch=${2:-"origin/staging"}
    echo "Pushing commits one by one from $target_branch"
    git log "$comparison_branch..$target_branch" --reverse --pretty="format:%h" | \
        xargs -I{} git push origin {}:"$target_branch" -f
}

# Copy file contents to clipboard
clip() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: clip <file...>" >&2
    return 1
  fi
  cat "$@" | pbcopy
  echo "📋 Copied $* to clipboard"
}

# Pick a file with fzf and copy its contents
clipf() { cat "$(fzf)" | pbcopy; }

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
