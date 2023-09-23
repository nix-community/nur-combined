# ntfy: UnifiedPush notification delivery system
# - used to get push notifications out of Matrix and onto a Phone (iOS, Android, or a custom client)
#
# config options:
# - <https://docs.ntfy.sh/config/#config-options>
#
# usage:
# - ntfy sub https://ntfy.uninsane.org/TOPIC
# - ntfy pub https://ntfy.uninsane.org/TOPIC "my message"
# in production, TOPIC is a shared secret between the publisher (Matrix homeserver) and the subscriber (phone)
#
# matrix integration:
# - the user must manually point synapse to the ntfy endpoint:
#   - `curl --header "Authorization: <your_token>" --data '{ "app_display_name": "sane-nix moby", "app_id": "ntfy.uninsane.org", "data": { "url": "https://ntfy.uninsane.org/_matrix/push/v1/notify", "format": "event_id_only" }, "device_display_name": "sane-nix moby", "kind": "http", "lang": "en-US", "profile_tag": "", "pushkey": "https://ntfy.uninsane.org/TOPIC" }' localhost:8008/_matrix/client/v3/pushers/set`
#     where the token is grabbed from Element's help&about page when logged in
#   - to remove, send this `curl` with `"kind": null`
{ lib, ... }:
{
  sane.persist.sys.plaintext = [
    # not sure if it's really necessary
    { user = "ntfy-sh"; group ="ntfy-sh"; path = "/var/lib/ntfy-sh"; }
  ];

  services.ntfy-sh.enable = true;
  services.ntfy-sh.settings = {
    base-url = "https://ntfy.uninsane.org";
    # behind-proxy = true;  # not sure if needed
    # keepalive interval is a ntfy-specific keepalive thing, where it sends actual data down the wire.
    # it's not simple TCP keepalive.
    # defaults to 45s.
    # note that the client may still do its own TCP-level keepalives, typically every 30s
    keepalive-interval = "15m";
    log-level = "trace";  # trace, debug, info (default), warn, error
  };

  systemd.services.ntfy-sh.serviceConfig.DynamicUser = lib.mkForce false;

  services.nginx.virtualHosts."ntfy.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2586";
      # proxyWebsockets = true;  #< before simplifying to this, ensure it doesn't add keepalives to the subscriber
      # support websocket upgrades. without that, `ntfy sub` hangs silently
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_buffering off;
        proxy_read_timeout 7d;
      '';
    };
  };
  sane.dns.zones."uninsane.org".inet.CNAME."ntfy" = "native";
}
