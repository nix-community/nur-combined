{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pdns-recursor;
in
{
  services.pdns-recursor = {
    # exportHosts = true;
    dns.address = [ "127.0.0.1" ];
    dnssecValidation = "off";
    old-settings = {
      trace = "fail";
      # max-negative-ttl = "5";
      # Disable auto update check.
      # https://doc.powerdns.com/authoritative/security.html#configuration-details
      # https://doc.powerdns.com/authoritative/settings.html#setting-security-poll-suffix
      security-poll-suffix = "";
      # log-timestamp = false;
      minimum-ttl-override = 3600;
      # quiet = false; # to enable the logging of queries
      # single-socket = true; # "Use only a single socket for outgoing queries."
      # tcp-fast-open = 100;
      # tcp-fast-open-connect = true;
      threads = 1;
    };
  };

  networking.nameservers = lib.mkIf cfg.enable [ "127.0.0.1" ];

  # TODO PR this upstream
  environment.systemPackages = lib.mkIf cfg.enable [ pkgs.pdns-recursor ];
}
