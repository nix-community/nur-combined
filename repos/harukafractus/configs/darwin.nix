{ mac-hostname, username }:
{ pkgs, home-manager, ... }: {
  networking.hostName = mac-hostname;

  nixpkgs.overlays = [ (import ../nur-everything/overlays/mac-apps) ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    utm
    iina
    librewolf
    qbittorrent
    telegram-desktop
    vscodium
    htop
    wget
    unar
    whisky
    lunarfyi
    sol
    python3Full
    libreoffice-bin
    imagemagick
  ];

  # Enable trackpad tap to click
  system.defaults.trackpad.Clicking = true;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;

  # Disable natural scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  # Show file extensions in finder.app
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  system.defaults.CustomUserPreferences = {
    # Enable Debug Menu
    NSGlobalDomain = { _NS_4445425547 = true; };

    # Disable .DS_Store Writing
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
      DSDontWriteStores = true;
    };
    # Finder: Show Folder on top; default to list view;  
    "com.apple.finder" = {
      _FXSortFoldersFirst = true;
      FXPreferredViewStyle = "Nlsv";
      FXEnableExtensionChangeWarning = false; # Changing file extension warning
    };
    # Show battery percentage
    "com.apple.controlcenter.plist" = { BatteryShowPercentage = true; };
  };

  # Define user 
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Configure zsh as an interactive shell.
  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import (./home.nix { inherit username; });
  };

  # Enable flakes and optimise store during every build
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
}
