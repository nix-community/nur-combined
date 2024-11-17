{ config, lib, ... }:
let
  cfg = config.sane.programs.yt-dlp;
in
{
  sane.programs.yt-dlp = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          defaultProfile = mkOption {
            type = types.enum [ "high-quality" "mid-range" "fast" ];
            default = "mid-range";
            description = ''
              exchange quality for size/cpu/power requirements.
            '';
          };
        };
      };
    };

    sandbox.net = "all";
    sandbox.whitelistPwd = true;  # saves to pwd by default
    fs.".config/yt-dlp/config".symlink.text = ''
      # this config file is CLI options, with whitespace and comments.
      # see the CONFIGURATION section of `man yt-dlp`.
      #
      # this config effects standalone `yt-dlp` AND users of it such as `mpv https://youtube.com/...`.

      # don't set the file's mtime to the https video's upload/edit date
      --no-mtime

      # to avoid frame drops or desync on low-power devices (lappy, moby, ...)
      # prefer sources at/under some max resolution, framerate, or codec version.
      # see `man yt-dlp` sections "Sorting Formats" and "Format Selection examples"
      #
      # further, prefer videos under a maximum bandwidth (tbr, in Kbps),
      # because others YouTube won't deliver it fast enough for > 1.0 play speed.
      # (e.g. a 1440p/30fps video might be 3000-6000 Kbps, and can't be downloaded at > 1.7x)
      #
      # see available formats: `yt-dlp -F https://youtube.com/<some_video>`
    '' + (if cfg.config.defaultProfile == "high-quality" then ''
      -S res:1440,fps:60,tbr:3000
    '' else if cfg.config.defaultProfile == "mid-range" then ''
      -S vcodec:h264,res:1080,fps:60,tbr:3000
    '' else ''
      -S vcodec:h264,height:360,fps:30,tbr:3000
    '');
  };
}
