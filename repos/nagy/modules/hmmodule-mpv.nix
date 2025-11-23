{
  config,
  pkgs,
  ...
}:

{
  imports = [ ./hmconvert.nix ];

  config.homeconfig.programs.mpv = {
    enable = config.services.xserver.enable;
    config = {
      # audio
      mute = "yes";
      ao = "pulse";
      # this gives better audio quality when speeding up a video
      # af = "rubberband";
      # dont show album covers when they are embedded in music files
      audio-display = "no";

      cache-secs = "60";
      sub-auto = "fuzzy";
      sid = "auto";
      ytdl-raw-options = "write-sub=,write-auto-sub=,sub-lang=en,sub-format=en,write-srt=";
      script-opts = "ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp";

      # https://nixos.wiki/wiki/Accelerated_Video_Playback
      hwdec = "auto-safe";
      vo = "gpu";
      profile = "gpu-hq";

      # info from here https://github.com/mpv-player/mpv/issues/2188
      title = "\${?media-title:\${media-title}}\${!media-title:No file.}";
      # https://news.ycombinator.com/item?id=32140083
      video-sync = "display-resample";
      screenshot-template = "%F - [%P] (%#01n)";
    };
    profiles = {
      "extension.webm" = {
        loop-file = "inf";
      };
      "extension.gif" = {
        loop-file = "inf";
      };
      "extension.mp4" = {
        loop-file = "inf";
      };
      "extension.png" = {
        # apng files
        loop-file = "inf";
        # keep-open = true;
        # image-display-duration = "inf";
      };
      # "extension.jpg" = {
      #   keep-open = true;
      #   image-display-duration = "inf";
      # };
      # "extension.jpeg" = {
      #   keep-open = true;
      #   image-display-duration = "inf";
      # };
      # "extension.jxl" = {
      #   keep-open = true;
      #   image-display-duration = "inf";
      # };
    };
    bindings = {
      k = "cycle pause";
      "Alt+-" = "add video-zoom -0.25";
      "Alt++" = "add video-zoom 0.25";
      "0" = "seek 0 absolute-percent+keyframes";
      "1" = "seek 10 absolute-percent+keyframes";
      "2" = "seek 20 absolute-percent+keyframes";
      "3" = "seek 30 absolute-percent+keyframes";
      "4" = "seek 40 absolute-percent+keyframes";
      "5" = "seek 50 absolute-percent+keyframes";
      "6" = "seek 60 absolute-percent+keyframes";
      "7" = "seek 70 absolute-percent+keyframes";
      "8" = "seek 80 absolute-percent+keyframes";
      "9" = "seek 90 absolute-percent+keyframes";
      "MBTN_MID" = "cycle fullscreen";
      "MBTN_LEFT" = "cycle pause";
      "WHEEL_UP" = "add volume 3";
      "WHEEL_DOWN" = "add volume -3";

      "UP" = "add volume 3";
      "DOWN" = "add volume -3";

      "Ü" = "add volume -3";
      "M" = "cycle ao-mute";

      "J" = "seek 60";
      "K" = "seek -60";

      # https://old.reddit.com/r/mpv/comments/bqz37b/hotkey_to_reset_zoom_brightness_at_once/
      "X" =
        "set contrast 0; set brightness 0; set gamma 0; set saturation 0; set hue 0; set video-zoom 0.0; set video-pan-x 0.0 ; set video-pan-y 0.0 ; ";

      # "æ" = "af set rubberband"; # altgr + a
      # "ſ" = "af remove rubberband"; # altgr + s

      "§" = "add brightness -1";
      "$" = "add brightness 1";
      "%" = "add gamma -1";
      "&" = "add gamma 1";
      "(" = "add saturation -1";
      ")" = "add saturation 1";

      "Alt+r" = ''cycle-values video-rotate  "90" "180" "270" "0"'';
      "Alt+|" = "vf toggle hflip";
      "a" = "vf toggle vflip";

      "Alt+h" = "add video-pan-x  0.1";
      "Alt+l" = "add video-pan-x -0.1";
      "Alt+k" = "add video-pan-y  0.1";
      "Alt+j" = "add video-pan-y -0.1";

      "Ctrl+Alt+j" = "add sub-scale -0.1";
      "Ctrl+Alt+k" = "add sub-scale +0.1";

      ":" = "script-binding console/enable";
    };
  };
}
