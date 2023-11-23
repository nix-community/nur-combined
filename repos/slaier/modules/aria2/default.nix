{ lib, ... }:
{
  services.aria2 = {
    enable = true;
    openPorts = true;
    extraArguments = lib.concatStringsSep " " [
      "--max-connection-per-server=8"
      "--min-split-size=1M"
      "--http-accept-gzip=true"
      "--seed-ratio=0.0"
      "--save-session=/var/lib/aria2/aria2.session"
      "--input-file=/var/lib/aria2/aria2.session"
      "--save-session-interval=5"
      "--https-proxy=http://127.0.0.1:7890"
      "--force-save=true"
    ];
  };
}
