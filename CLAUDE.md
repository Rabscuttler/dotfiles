# CLAUDE.md — Dotfiles

## How this repo works

Dotfiles are tracked with a **bare git repo** at `~/git/dotfiles` with `$HOME` as the worktree.
A `*` gitignore blocks everything by default — files are explicitly added with `dot add -f`.

```bash
dot status                  # what changed?
dot diff                    # see changes
dot add -f ~/.config/foo    # track a new file
dot commit -m "update foo"
dot push
ldot                        # lazygit for dotfiles
```

## Package management

CLI tools are managed declaratively via **Nix flakes**:
- **macOS**: nix-darwin + home-manager (`drs` to rebuild)
- **Linux (NUC)**: home-manager standalone (`hms` to rebuild)
- **Update packages**: `nfu` (nix flake update), then `drs` or `hms`

Homebrew is only used for **macOS GUI casks** — defined in `darwin.nix`.
Rust (rustup) and Node (NVM) are managed manually.

## Key files

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config — cross-platform with OS guards |
| `.zshenv` | Homebrew shellenv (macOS) |
| `.zprofile` | Login shell setup |
| `.gitconfig` | Git config (also partially managed by Nix home-manager) |
| `.gitignore` | `*` — blocks everything, files are force-added |
| `.ssh/config` | SSH host config (keys NOT tracked) |
| `.ssh/config.d/private` | Private SSH hosts (NOT tracked) |
| `.config/nix/flake.nix` | Main Nix config — two targets (Mac + NUC) |
| `.config/nix/modules/packages.nix` | CLI tool lists (core + workstation tiers) |
| `.config/nix/modules/shared.nix` | Cross-platform home-manager config |
| `.config/nix/modules/darwin.nix` | macOS: system.defaults, homebrew casks |
| `.config/nix/modules/linux.nix` | NUC: home-manager standalone |
| `.config/nvim/init.lua` | Neovim config (lazy.nvim) |
| `.config/ghostty/config` | Ghostty terminal config |
| `.config/ghostty/bin/theme-random` | Random theme switcher |
| `.config/ghostty/bin/theme-reset` | Reset to default theme |
| `.config/karabiner/karabiner.json` | Keyboard remapping |
| `.config/starship.toml` | Prompt config |
| `.config/atuin/config.toml` | Shell history config |
| `.config/direnv/direnv.toml` | Auto-activate Python venvs |
| `.claude/settings.json` | Claude Code settings |
| `install.sh` | Bootstrap script (installs Nix, Rust, NVM) |
| `README.md` | Setup guide |

## Important conventions

- **Never track secrets**: no `.env`, `.netrc`, SSH keys, API tokens
- **Force-add only**: use `dot add -f` since the gitignore blocks everything
- **Two platforms**: macOS (aarch64-darwin) and Ubuntu 24.04 (x86_64-linux)
- Ghostty theme scripts in `.config/ghostty/bin/` must be executable

## Git hygiene

- Ignore unrelated changes — don't reset/revert/discard files you didn't change
- Keep commits focused: one logical change per commit
