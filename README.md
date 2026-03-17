# dotfiles

My macOS dotfiles, managed as a bare git repo with `$HOME` as the worktree.

## What's tracked

- **Shell** — zsh config (`.zshrc`, `.zshenv`, `.zprofile`)
- **Git** — `.gitconfig`
- **Terminal** — [Ghostty](https://ghostty.org/) config + theme scripts
- **Editor** — Neovim (`init.lua`)
- **Keyboard** — Karabiner-Elements (caps→esc, ctrl↔cmd on external keyboards)
- **Prompt** — [Starship](https://starship.rs/)
- **Shell history** — [Atuin](https://atuin.sh/)
- **Direnv** — auto-activate Python venvs
- **SSH** — config (not keys)
- **Claude Code** — settings + hooks

## How it works

The git metadata lives in `~/git/dotfiles` (a bare repo). The working tree is `$HOME`.
A `*` gitignore blocks everything by default — files are explicitly added with `dot add -f`.

### Daily use

```bash
dot status                      # what changed?
dot add -f ~/.config/foo        # track a new file
dot commit -m "update foo"
dot push

ldot                            # lazygit for dotfiles
```

## Setup on a new Mac

```bash
# 1. Install Xcode CLI tools + Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install git (comes with Xcode tools, or brew install git)

# 3. Clone bare repo
git clone --bare git@github.com:rabscuttler/dotfiles.git ~/git/dotfiles

# 4. Define the alias temporarily
alias dot='git --git-dir=$HOME/git/dotfiles --work-tree=$HOME'

# 5. Checkout — back up any conflicts first
dot checkout 2>&1 | grep "^\t" | xargs -I{} mv {} {}.bak
dot checkout

# 6. Run install script
~/install.sh
```
