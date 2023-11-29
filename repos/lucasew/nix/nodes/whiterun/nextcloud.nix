{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.nextcloud.enable {
    services.nextcloud.package = pkgs.nextcloud27;
    users.users.nextcloud = {
      extraGroups = [ "admin-password" "render" ];
    };
    services.nextcloud = {
      configureRedis = true;
      hostName = "nextcloud.${config.networking.hostName}.${config.networking.domain}";
      config = {
        dbtype = "pgsql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        adminuser = "lucasew";
        adminpassFile = "/var/run/secrets/admin-password";
      };
      extraOptions = {
        preview_ffmpeg_path = lib.getExe pkgs.ffmpeg;
        "memories.exiftool" = lib.getExe pkgs.exiftool;
        "memories.ffmpeg_path" = lib.getExe' pkgs.ffmpeg "ffmpeg";
        "memories.ffprobe_path" = lib.getExe' pkgs.ffmpeg "ffprobe";
        "memories.vod.ffmpeg" = lib.getExe' pkgs.ffmpeg "ffmpeg";
        "memories.vod.ffprobe" = lib.getExe' pkgs.ffmpeg "ffprobe";
        recognize = {
          nice_binary = lib.getExe' pkgs.coreutils "nice";
        };
        enabledPreviewProviders = [
          "OC\\Preview\\AVI"
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\HEIC"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MKV"
          "OC\\Preview\\Movie"
          "OC\\Preview\\MP3"
          "OC\\Preview\\MP4"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PDF"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
        ];
      };
    };

    systemd.services.nextcloud-setup = {
      requires = ["postgresql.service"];
      after = ["postgresql.service"];

      script = ''
        # extra steps
        ln -sf ${lib.getExe pkgs.nodejs} ${config.services.nextcloud.datadir}/store-apps/recognize/bin/node
        ln -sf ${lib.getExe pkgs.exiftool} ${config.services.nextcloud.datadir}/store-apps/memories/bin-ext/exiftool/exiftool
      '';
    };

    services.postgresqlBackup.databases = [ "nextcloud" ];

    services.postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {name = "nextcloud"; ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";}
      ];
    };
  };
}
