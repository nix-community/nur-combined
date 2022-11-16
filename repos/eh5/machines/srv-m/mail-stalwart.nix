{ config, pkgs, lib, ... }:
let
  cfg = config.mail;
in
{
  services.stalwart-jmap.enable = true;
  services.stalwart-jmap.config = {
    log-level = "debug";
    jmap-bind-addr = "127.0.0.1";
    jmap-port = 18080;
    jmap-url = "https://mail.eh5.me/jmap";
    worker-pool-size = 2;
    lmtp-bind-addr = "127.0.0.1";
    lmtp-port = 11200;
    smtp-relay-host = "127.0.0.1";
    smtp-relay-port = 25;
    smtp-relay-tls = false;
    use-forwarded-header = true;
  };

  services.caddy.virtualHosts = {
    "mail.eh5.me".extraConfig = lib.mkAfter ''
      rewrite /.well-known/jmap /jmap/.well-known/jmap
      handle_path /jmap* {
        reverse_proxy http://127.0.0.1:18080
      }
    '';
  };

  environment.systemPackages = [ pkgs.stalwart-cli ];
}
