# yt-dlp plugin list: <https://github.com/topics/yt-dlp-plugins>
#
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

      # restrict to ascii characters only (seems to include replacing ' ' with '_')
      --restrict-filenames
      # man yt-dlp  ## OUTPUT TEMPLATE
      -o %(uploader)s-%(title)s.%(ext)s
      # for curlftpfs compatibility; see: <https://github.com/kahing/goofys/issues/296>
      --postprocessor-args -movflags\ frag_keyframe+empty_moov

      # sponsor, intro, outro, selfpromo, preview, filler, interaction, music_offtopic, poi_highlight, chapter, all
      --sponsorblock-mark intro,outro,selfpromo,sponsor
      --sponsorblock-chapter-title %(category_names)l

      # to avoid frame drops or desync on low-power devices (lappy, moby, ...)
      # prefer sources at/under some max resolution, framerate, or codec version.
      # see `man yt-dlp` sections "Sorting Formats" and "Format Selection examples"
      #
      # further, prefer videos under a maximum bandwidth (tbr, in Kbps),
      # because others YouTube won't deliver it fast enough for > 1.0 play speed.
      # (e.g. a 1440p/30fps video might be 3000-6000 Kbps, and can't be downloaded at > 1.7x)
      #
      # see available formats: `yt-dlp -F https://youtube.com/<some_video>`
      #
      # `res:1080` means "prefer the best resolution <= 1080, followed by the _worst_ resolution > 1080"
      # `res~360` means "prefer the resolution _closest to_ 360, whether that's larger _or_ smaller than 360
      # typical resolutions:
      # - 256x144
      # - 426x240
      # - 640x360
      # - 854x480
      # - 1280x720
      # - 1920x1080
      # - 2560x1440
      # - 3840x2160
      #
      # default sort ordering: lang,quality,res,fps,hdr:12,vcodec,channels,acodec,size,br,asr,proto,ext,hasaud,source,id.
      # vcodec default ordering: av01 > vp9.2 > vp9 > h265 > h264 > vp8 > h263 > theora > other
      #
      # desko LG display is 5360x1440
      --alias profile-high-quality -S\ lang,res~1440,fps:60,vcodec,br:3000
      # flowy HP display is 1920x1200. res~1200 causes priority: 1080 > 1440 > 720
      --alias profile-mid-range -S\ lang,res~1200,vcodec:vp9,fps:60,br:3000
      # PinePhone Pro display is 360x720. but low-res video is associated with low bits-per-pixel, so request higher-res & downscale.
      --alias profile-fast -S\ lang,vcodec:h264,res~480,fps:30,br:1500

      --profile-${cfg.config.defaultProfile}
    '';
  };
}
