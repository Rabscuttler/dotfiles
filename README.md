# dotfiles

My dotfiles, managed as a bare git repo with `$HOME` as the worktree. Uses [nix-darwin](https://github.com/LnL7/nix-darwin) (macOS) and [home-manager](https://github.com/nix-community/home-manager) (Linux) for declarative package management.

## Setup

```bash
curl -fsSL https://raw.githubusercontent.com/Rabscuttler/dotfiles/main/install.sh | bash
```

This will:
1. Install Nix ([Determinate Systems](https://determinate.systems/))
2. Clone this repo as a bare repo at `~/git/dotfiles`
3. Checkout dotfiles into `$HOME` (backing up conflicts)
4. **macOS**: install Homebrew, run nix-darwin
5. **Linux**: run home-manager, set zsh as default shell
6. Install Rust (rustup) and NVM

## Daily use

```bash
dot status                      # what changed?
dot add -f ~/.config/foo        # track a new file
dot commit -m "update foo"
dot push
dotlg                           # lazygit for dotfiles
```

### Managing packages

```bash
# macOS — rebuild nix-darwin config
drs                             # darwin-rebuild switch --flake ~/.config/nix

# Linux — rebuild home-manager config
hms                             # home-manager switch --flake ~/.config/nix

# Update nix packages (both platforms), then run drs or hms
nfu                             # nix flake update --flake ~/.config/nix
```

## What's tracked

- **Shell** — `.zshrc`, `.zshenv`, `.zprofile`
- **Nix** — `flake.nix` + modules (packages, darwin, linux, shared)
- **Editor** — Neovim (`init.lua`)
- **Terminal** — [Ghostty](https://ghostty.org/) config + theme scripts
- **Keyboard** — Karabiner-Elements
- **Prompt** — [Starship](https://starship.rs/)
- **Git** — managed by Nix home-manager
- **SSH** — config (not keys)

## Inspired by

[Connor Adams](https://github.com/connorads/dotfiles)
