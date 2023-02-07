{ config, pkgs, ... }:
let secrets = builtins.fromJSON (builtins.readFile /secrets/jellyfin.json);
in {
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [ mopidy-jellyfin mopidy-muse ];
    configuration = ''
      [audio]
      mixer = none
      output = pulsesink
      [stream]
      enabled = true
      protocols =
          http
          https
          mms
          rtmp
          rtmps
          rtsp
      [http]
      enabled = true
      hostname = 0.0.0.0
      port = 6680
      zeroconf = Mopidy HTTP Server
      csrf_protection = true
      default_app = muse
      [muse]
      enabled = true
      [file]
      enabled = false
      [m3u]
      enabled = false
      [jellyfin]
      enabled = true
      hostname = https://jellyfin.rovacsek.com
      username = ${secrets.username}
      password = ${secrets.password}
      album_format = {ProductionYear} - {Name}'';
  };
}
