# Homebrew (macOS only)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Nix home-manager profile (Linux)
if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
