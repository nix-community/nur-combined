{
  # System-wide defaults
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        "com.apple.swipescrolldirection" = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      menuExtraClock = {
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 1;
        ShowDayOfWeek = true;
        ShowSeconds = true;
      };

      controlcenter = {
        BatteryShowPercentage = true;
        Sound = true;
        FocusModes = true;
        NowPlaying = false;
      };
      iCal.CalendarSidebarShown = true;
      iCal."TimeZone support enabled" = true;
      screencapture.location = "/Users/avy/Desktop/screenshots";
      screensaver.askForPassword = true;
      screensaver.askForPasswordDelay = 0;

      # Dock settings
      dock = {
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        mineffect = "genie";
        mru-spaces = false;
        expose-group-apps = true;
        # Top left quick action = nothing
        wvous-tl-corner = 1;
        # bottom left quick action = desktop
        wvous-bl-corner = 4;
        # Top right quick action = application windows
        wvous-tr-corner = 3;
        # bottom right quick action = Dashboard (apps?)/spotlight apps
        wvous-br-corner = 7;

      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
        ShowStatusBar = true;
        ShowPathbar = true;
      };

      # Trackpad settings
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
    };

    # System-wide keyboard settings
    keyboard = {
      enableKeyMapping = true;
    };

    activationScripts.postActivation.text = ''
      # Following line should allow us to avoid a logout/login cycle
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      launchctl stop com.apple.Dock.agent
      launchctl start com.apple.Dock.agent
    '';
  };
  launchd.daemons.apfs-cleanup = {
    # for whatever reason, rosetta keeps garbage around until we run this command
    script = ''
      date
      /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -P -minsize 0 /System/Volumes/Data
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Hour = 2;
          Minute = 30;
        }
      ];
      StandardErrorPath = "/var/log/apfs-cleanup.log";
      StandardOutPath = "/var/log/apfs-cleanup.log";
    };
  };
}
