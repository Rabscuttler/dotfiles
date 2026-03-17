#!/usr/bin/env bash

# List of themes you like
themes=("Catppuccin Latte" "Gruvbox Dark" "Dracula" "Solarized Light" "Tokyo Night")

# Pick one randomly
random_theme=${themes[$RANDOM % ${#themes[@]}]}

# Apply it
ghostty +set theme="$random_theme"
