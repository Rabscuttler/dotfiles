# dotfiles

My dotfiles, managed as a bare git repo with `$HOME` as the worktree. Uses [nix-darwin](https://github.com/LnL7/nix-darwin) (macOS) and [home-manager](https://github.com/nix-community/home-manager) (Linux) for declarative package management.

## What's tracked

- **Shell** — zsh config (`.zshrc`, `.zshenv`, `.zprofile`)
- **Git** — `.gitconfig` (managed by Nix home-manager)
- **Terminal** — [Ghostty](https://ghostty.org/) config + theme scripts
- **Editor** — Neovim (`init.lua`)
- **Keyboard** — Karabiner-Elements
- **Prompt** — [Starship](https://starship.rs/)
- **Shell history** — [Atuin](https://atuin.sh/)
- **Direnv** — auto-activate Python venvs
- **SSH** — config (not keys)
- **Claude Code** — settings
- **Nix** — flake + modules for both machines

## How it works

Git metadata lives in `~/git/dotfiles` (a bare repo). The working tree is `$HOME`.
A `*` gitignore blocks everything — files are explicitly added with `dot add -f`.

### Daily use

```bash
dot status                      # what changed?
dot add -f ~/.config/foo        # track a new file
dot commit -m "update foo"
dot push
ldot                            # lazygit for dotfiles
```

### Managing packages

```bash
# macOS — rebuild nix-darwin config
drs                             # darwin-rebuild switch --flake ~/.config/nix

# Linux (NUC) — rebuild home-manager config
hms                             # home-manager switch --flake ~/.config/nix

# Update nix packages (both platforms)
nfu                             # nix flake update --flake ~/.config/nix
# Then run drs or hms to activate
```

## Setup on a new Mac

```bash
# 1. Install Homebrew (for GUI casks only)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install Nix (Determinate Systems)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 3. Clone bare repo
git clone --bare git@github.com:rabscuttler/dotfiles.git ~/git/dotfiles

# 4. Define the alias temporarily
alias dot='git --git-dir=$HOME/git/dotfiles --work-tree=$HOME'

# 5. Checkout — back up any conflicts first
dot checkout 2>&1 | grep "^\t" | xargs -I{} mv {} {}.bak
dot checkout

# 6. Build and activate nix-darwin
nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix

# 7. Run install script for Rust, NVM, etc.
~/install.sh
```

## Setup on Linux (NUC)

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. Install git + zsh
sudo apt update && sudo apt install -y git zsh

# 3. Clone bare repo
git clone --bare git@github.com:rabscuttler/dotfiles.git ~/git/dotfiles
alias dot='git --git-dir=$HOME/git/dotfiles --work-tree=$HOME'
dot checkout 2>&1 | grep "^\t" | xargs -I{} mv {} {}.bak
dot checkout

# 4. Build and activate home-manager
nix run home-manager/master -- switch --flake ~/.config/nix#laurence@nuc

# 5. Set zsh as default shell
chsh -s $(which zsh)

# 6. Run install script for Rust, NVM, etc.
~/install.sh
```

## Inspired by

Connor Adams: https://github.com/connorads/dotfiles
