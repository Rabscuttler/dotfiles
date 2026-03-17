#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing dotfiles dependencies..."

# Xcode CLI tools (skip if already installed)
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Press any key once installation is complete."
  read -n 1 -s
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Brew bundle (if Brewfile exists)
if [[ -f "$HOME/Brewfile" ]]; then
  echo "==> Installing Homebrew packages..."
  brew bundle --file="$HOME/Brewfile"
fi

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

# macOS defaults
echo "==> Applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 54

# Finder — uncomment if you want these
# defaults write com.apple.finder AppleShowAllFiles -bool true
# defaults write com.apple.finder ShowPathbar -bool true
# defaults write com.apple.finder ShowStatusBar -bool true

# Fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Trackpad — tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Trackpad — three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Screenshots to ~/Downloads
defaults write com.apple.screencapture location -string "$HOME/Downloads"

echo "==> Restarting affected apps..."
killall Dock Finder 2>/dev/null || true

echo "==> Done! Open a new terminal to pick up shell changes."
