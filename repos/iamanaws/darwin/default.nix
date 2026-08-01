{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./homebrew.nix
    ./nix.nix
    ./programs/gnupg.nix
  ];

  power.sleep = {
    # minutes before sleep
    computer = 15;
    display = 5;
  };

  system.defaults = {
    ".GlobalPreferences"."com.apple.mouse.scaling" = 5.0;

    NSGlobalDomain = {
      AppleEnableMouseSwipeNavigateWithScrolls = false;
      AppleEnableSwipeNavigateWithScrolls = false;
      AppleICUForce24HourTime = false;
      # AppleInterfaceStyle = Dark;
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      ApplePressAndHoldEnabled = true;
      AppleScrollerPagingBehavior = true;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = false;
      AppleShowScrollBars = "Automatic";
      AppleSpacesSwitchOnActivate = true;
      AppleTemperatureUnit = "Celsius";
      InitialKeyRepeat = 30;
      KeyRepeat = 5;
      NSDocumentSaveNewDocumentsToCloud = false;
      # "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.trackpad.scaling" = 3.0;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    controlcenter = {
      AccessibilityShortcuts = "hide";
      AirDrop = "hide";
      Battery = "menuBar";
      BatteryShowEnergyMode = "whenActive";
      BatteryShowPercentage = false;
      Bluetooth = "hide";
      Display = "whenActive";
      FocusModes = "whenActive";
      Hearing = "hide";
      KeyboardBrightness = "hide";
      MusicRecognition = "hide";
      NowPlaying = "whenActive";
      ScreenMirroring = "whenActive";
      Sound = "whenActive";
      StageManager = "hide";
      UserSwitcher = "hide";
      WiFi = "hide";
    };

    Spotlight.MenuItemHidden = true;

    loginwindow = {
      GuestEnabled = false;
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 0;
      ShowDayOfWeek = true;
    };

    spaces.spans-displays = true;

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 5;
    };
  };

  # Enable MAS (Mac App Store) support
  programs.mas = {
    enable = true;
    cleanup = true;
  };
  # programs.mas.packages = { };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    alt-tab-macos
    beekeeper-studio
    # brave
    ghostty-bin
    iina
    rectangle

    bottom
    fet-sh
    neovim
    sops
    zstd
  ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
