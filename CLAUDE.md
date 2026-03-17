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

The `dot` alias is defined in `.zshrc`:
```bash
alias dot='git --git-dir=$HOME/git/dotfiles --work-tree=$HOME'
alias ldot='lazygit -g $HOME/git/dotfiles -w $HOME'
```

## Key files

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config — aliases, functions, keybindings, tool init |
| `.zshenv` | Homebrew shellenv (runs for all zsh instances) |
| `.zprofile` | Login shell setup |
| `.gitconfig` | Git config |
| `.gitignore` | `*` — blocks everything, files are force-added |
| `.ssh/config` | SSH host config (keys are NOT tracked) |
| `.config/nvim/init.lua` | Neovim config (lazy.nvim) |
| `.config/ghostty/config` | Ghostty terminal config |
| `.config/ghostty/bin/theme-random` | Random theme switcher (bound to keybind) |
| `.config/ghostty/bin/theme-reset` | Reset to default theme |
| `.config/karabiner/karabiner.json` | Keyboard remapping |
| `.config/starship.toml` | Prompt config |
| `.config/atuin/config.toml` | Shell history config |
| `.config/direnv/direnv.toml` | Auto-activate Python venvs |
| `.claude/settings.json` | Claude Code settings |
| `Brewfile` | Homebrew dependencies |
| `install.sh` | Bootstrap script for new Macs |
| `README.md` | Setup guide |

## Important conventions

- **Never track secrets**: no `.env`, `.netrc`, SSH keys, API tokens
- **Force-add only**: use `dot add -f` since the gitignore blocks everything
- **macOS only** for now — no Linux conditional logic yet
- Homebrew packages are managed via `Brewfile` — run `brew bundle` to install
- macOS system preferences are set via `defaults write` commands in `install.sh`
- Ghostty theme scripts in `.config/ghostty/bin/` must be executable

## Git hygiene

- Ignore unrelated changes — don't reset/revert/discard files you didn't change
- Keep commits focused: one logical change per commit
