{
  self,
  pkgs,
  packages,
  ...
}:
{
  # -- Homebrew (casks + Mac App Store) --
  homebrew = {
    enable = true;
    taps = [
      "peonping/tap"
    ];
    brews = [
      "mole"
      "peonping/tap/peon-ping"
    ];
    casks = [
      "1password"
      "alfred"
      "alt-tab"
      "cursor"
      "discord"
      "firefox"
      "ghostty"
      "google-chrome"
      "gpg-suite"
      "karabiner-elements"
      "obsidian"
      "rectangle"
      "slack"
      "spotify"
      "tailscale"
      "vlc"
      "whatsapp"
    ];
  };

  system.primaryUser = "laurence";

  # -- System Defaults (macOS preferences) --
  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 54;
      show-recents = false;
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 25;
      "com.apple.swipescrolldirection" = false;
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
    };
    # Disable Spotlight shortcut (Cmd+Space) — Alfred replaces it
    CustomSystemPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "64" = { enabled = false; };  # Cmd+Space (Spotlight)
          "65" = { enabled = false; };  # Cmd+Alt+Space (Finder search)
        };
      };
    };
    CustomUserPreferences = {
      "com.apple.AppleMultitouchTrackpad" = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
      "com.apple.screencapture" = {
        location = "~/Downloads";
      };
    };
  };

  # -- Nix Settings --
  # Determinate Systems manages the Nix daemon, so disable nix-darwin's management
  nix.enable = false;

  # -- Programs --
  programs.zsh.enable = true;

  # -- Users & Home Manager --
  users.users.laurence.home = "/Users/laurence";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.laurence = {
      imports = [ ./shared.nix ];
      home.username = "laurence";
      home.homeDirectory = "/Users/laurence";
      home.packages = packages.workstationPackages;
      home.stateVersion = "24.11";

      # Git credential helper is auto-configured by programs.gh
    };
  };

  # Set Git commit hash for darwin-version
  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
