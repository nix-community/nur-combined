{ pkgs, ... }:
let
  bg = "backgrounds/nixos/nix-wallpaper-dracula.png";
  bgPath = "${pkgs.nixos-artwork.wallpapers.dracula}/share/${bg}";
  noproxy = cmd: "env -u http_proxy -u https_proxy -u ftp_proxy -u rsync_proxy -u all_proxy ${cmd}";
in
{
  home.packages = [ pkgs.swaybg ];
  xdg.dataFile."${bg}".source = bgPath;
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;
  services.swayidle =
    let
      # Lock command
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize -i ${bgPath}";
      # Niri
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
      enable = true;
      systemdTargets = [ "niri.service" ];
      timeouts = [
        {
          timeout = 300; # in seconds
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 30 seconds' -t 30000";
        }
        {
          timeout = 330;
          command = lock;
        }
        {
          timeout = 360;
          command = display "off";
          resumeCommand = display "on";
        }
      ];
      events = {
        before-sleep = (display "off") + "; " + lock;
        after-resume = display "on";
        lock = (display "off") + "; " + lock;
        unlock = display "on";
      };
    };
  xdg.desktopEntries = {
    "chromium-browser" = {
      name = "Chromium (Custom)";
      genericName = "Web Browser";
      comment = "Access the Internet";
      exec = noproxy "chromium %U";
      icon = "chromium";
      terminal = false;
      startupNotify = true;
      categories = [
        "Network"
        "WebBrowser"
      ];
    };
    piliplus = {
      name = "PiliPlus";
      comment = "Third-party Bilibili client developed in Flutter";
      exec = noproxy "piliplus";
      icon = "piliplus";
      categories = [
        "Video"
        "AudioVideo"
      ];
    };
    "scrcpy" = {
      name = "scrcpy";
      genericName = "Android Remote Control";
      comment = "Display and control your Android device";
      exec = noproxy "scrcpy --video-bit-rate 16M --render-driver=opengl -f -S";
      icon = "scrcpy";
      terminal = false;
      categories = [
        "Utility"
        "RemoteAccess"
      ];
      startupNotify = false;
    };
    "com.heroicgameslauncher.hgl" = {
      name = "Heroic Games Launcher";
      exec = "env http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 heroic %u";
      icon = "com.heroicgameslauncher.hgl";
      terminal = false;
      comment = "An Open Source Launcher for GOG, Epic Games and Amazon Games";
      mimeType = [
        "x-scheme-handler/heroic"
      ];
      categories = [
        "Game"
      ];
    };
    tauonmb = {
      # ponytail: nixpkgs tauon renames bin tauonmb->tauon but desktop Exec still tauonmb; override Exec via xdg to fix fuzzel. Remove when upstream patches extra/tauonmb.desktop.
      name = "Tauon";
      genericName = "Audio Player";
      comment = "Ultra player for your music collection";
      exec = "tauon %U";
      icon = "tauonmb";
      terminal = false;
      type = "Application";
      categories = [
        "AudioVideo"
        "Player"
        "Audio"
      ];
      mimeType = [
        "application/ogg"
        "audio/x-vorbis+ogg"
        "application/x-ogg"
        "audio/ogg"
        "audio/x-ogg"
        "audio/x-opus+ogg"
        "audio/flac"
        "audio/x-flac"
        "application/flac"
        "audio/wav"
        "audio/x-wav"
        "audio/tta"
        "audio/x-tta"
        "audio/mpeg"
        "audio/mp3"
        "audio/x-mp3"
        "audio/m4a"
        "audio/x-m4a"
        "audio/ape"
        "audio/x-ape"
        "x-content/audio-player"
        "audio/scpls"
        "audio/x-scpls"
        "audio/x-pls"
        "audio/m3u"
        "application/xspf+xml"
      ];
      startupNotify = false;
      actions = {
        PlayPause = {
          name = "Play/Pause";
          exec = "tauon playpause";
        };
        Previous = {
          name = "Previous Track";
          exec = "tauon prev";
        };
        Next = {
          name = "Next Track";
          exec = "tauon next";
        };
        Stop = {
          name = "Stop";
          exec = "tauon stop";
        };
      };
      settings = {
        StartupWMClass = "Tauon Music Box";
        "X-GNOME-UsesNotifications" = "true";
      };
    };
  };
}
