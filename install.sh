#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
DOTFILES_REPO="https://github.com/Rabscuttler/dotfiles.git"
DOTFILES_DIR="$HOME/git/dotfiles"

echo "==> Setting up dotfiles on $OS..."

# ─── Prerequisites (Linux) ───────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  for pkg in git zsh curl; do
    if ! command -v "$pkg" &>/dev/null; then
      echo "==> Installing $pkg..."
      sudo apt-get update -y && sudo apt-get install -y "$pkg"
    fi
  done
fi

# ─── Install Nix (Determinate Systems) ───────────────────────────────
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# ─── Clone dotfiles ──────────────────────────────────────────────────
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "==> Cloning dotfiles..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

  _dot() { git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

  # Backup any conflicting files
  _dot checkout 2>&1 | grep "^\t" | while IFS= read -r file; do
    file="${file#"${file%%[![:space:]]*}"}"  # trim leading whitespace
    if [[ -f "$HOME/$file" ]]; then
      echo "    Backing up $file -> $file.bak"
      mv "$HOME/$file" "$HOME/$file.bak"
    fi
  done
  _dot checkout -f

  echo "==> Dotfiles checked out."
else
  echo "==> Dotfiles already cloned, pulling latest..."
  git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" pull || true
fi

# ─── macOS ───────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  # Xcode CLI tools
  if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "    Press any key once installation is complete."
    read -n 1 -s
  fi

  # Homebrew (for casks only — CLI tools come from Nix)
  if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # Build and activate nix-darwin configuration
  echo "==> Running nix-darwin switch (requires sudo)..."
  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix
fi

# ─── Linux ───────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  # Build and activate home-manager configuration
  echo "==> Running home-manager switch..."
  nix run home-manager/master -- switch -b backup --flake ~/.config/nix#laurence@nuc

  # Set zsh as default shell
  ZSH_PATH="$(which zsh 2>/dev/null || true)"
  if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
    echo "==> Setting zsh as default shell..."
    # Add to /etc/shells if not already there
    grep -qxF "$ZSH_PATH" /etc/shells 2>/dev/null || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
  fi
fi

# ─── Cross-platform ─────────────────────────────────────────────────
# Rust / Cargo
if ! command -v cargo &>/dev/null; then
  echo "==> Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
fi

# NVM + Node
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Make ghostty bin scripts executable
chmod +x "$HOME/.config/ghostty/bin/"* 2>/dev/null || true
chmod +x "$HOME/.config/ghostty/random_theme.sh" 2>/dev/null || true

echo "==> Done! Open a new terminal (or run 'exec zsh -l') to pick up shell changes."
