#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
echo "==> Setting up dotfiles on $OS..."

# ─── Install Nix (Determinate Systems) ────────────────────────────────
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # Source nix for this session
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
fi

# ─── macOS ────────────────────────────────────────────────────────────
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
  echo "==> Running nix-darwin switch..."
  nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/nix
fi

# ─── Linux ────────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  # Install zsh if not present
  if ! command -v zsh &>/dev/null; then
    echo "==> Installing zsh..."
    sudo apt-get update && sudo apt-get install -y zsh
  fi

  # Build and activate home-manager configuration
  echo "==> Running home-manager switch..."
  nix run home-manager/master -- switch -b backup --flake ~/.config/nix#laurence@nuc

  # Set zsh as default shell
  ZSH_PATH="$(which zsh)"
  if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "==> Setting zsh as default shell..."
    chsh -s "$ZSH_PATH"
  fi
fi

# ─── Cross-platform ──────────────────────────────────────────────────
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

echo "==> Done! Open a new terminal to pick up shell changes."
