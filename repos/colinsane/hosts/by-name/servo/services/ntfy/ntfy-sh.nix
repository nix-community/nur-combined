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
# administering:
# - sudo -u ntfy-sh ntfy access
#
# debugging:
# - make sure that the keepalives are good:
#   - on the subscriber machine, run `lsof -i4` to find the port being used
#   - `sudo tcpdump tcp port <p>`
#     - shouldn't be too spammy
#
# matrix integration:
# - the user must manually point synapse to the ntfy endpoint:
#   - `curl --header "Authorization: <your_token>" --data '{ "app_display_name": "sane-nix moby", "app_id": "ntfy.uninsane.org", "data": { "url": "https://ntfy.uninsane.org/_matrix/push/v1/notify", "format": "event_id_only" }, "device_display_name": "sane-nix moby", "kind": "http", "lang": "en-US", "profile_tag": "", "pushkey": "https://ntfy.uninsane.org/TOPIC" }' localhost:8008/_matrix/client/v3/pushers/set`
#     where the token is grabbed from Element's help&about page when logged in
#   - to remove, send this `curl` with `"kind": null`
{ config, lib, pkgs, ... }:
let
  # subscribers need a non-443 public port to listen on as a way to easily differentiate this traffic
  # at the IP layer, to enable e.g. wake-on-lan.
  altPort = 2587;
in
lib.mkIf false  #< 2024/09/30: disabled because i haven't used it in several months
{
  sane.persist.sys.byStore.private = [
    # not 100% necessary to persist this, but ntfy does keep a 12hr (by default) cache
    # for pushing notifications to users who become offline.
    # ACLs also live here.
    { user = "ntfy-sh"; group ="ntfy-sh"; path = "/var/lib/ntfy-sh"; method = "bind"; }
  ];

  services.ntfy-sh.enable = true;
  services.ntfy-sh.settings = {
    base-url = "https://ntfy.uninsane.org";
    behind-proxy = true;  # not sure if needed
    # keepalive interval is a ntfy-specific keepalive thing, where it sends actual data down the wire.
    # it's not simple TCP keepalive.
    # defaults to 45s.
    # note that the client may still do its own TCP-level keepalives, typically every 30s
    keepalive-interval = "15m";
    log-level = "info";  # trace, debug, info (default), warn, error
    auth-default-access = "deny-all";
  };
  systemd.services.ntfy-sh.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.ntfy-sh.preStart = ''
    # make this specific topic read-write by world
    # it would be better to use the token system, but that's extra complexity for e.g.
    # how do i plumb a secret into the Matrix notification pusher
    #
    # note that this will fail upon first run, i.e. before ntfy has created its db.
    # just restart the service.
    topic=$(cat ${config.sops.secrets.ntfy-sh-topic.path})
    ${lib.getExe' pkgs.ntfy-sh "ntfy"} access everyone "$topic" read-write
  '';


  services.nginx.virtualHosts."ntfy.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    listen = [
      { addr = "0.0.0.0"; port = altPort; ssl = true; }
      { addr = "0.0.0.0"; port = 443;  ssl = true; }
      { addr = "0.0.0.0"; port = 80;   ssl = false; }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:2586";
      proxyWebsockets = true;  #< support websocket upgrades. without that, `ntfy sub` hangs silently
      recommendedProxySettings = true; #< adds headers so ntfy logs include the real IP
      extraConfig = ''
        # absurdly long timeout (86400s=24h) so that we never hang up on clients.
        # make sure the client is smart enough to detect a broken proxy though!
        proxy_read_timeout 86400s;
      '';
    };
  };
  sane.dns.zones."uninsane.org".inet.CNAME."ntfy" = "native";

  sane.ports.ports."${builtins.toString altPort}" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    visibleTo.doof = true;
    description = "colin-ntfy.uninsane.org";
  };
}
