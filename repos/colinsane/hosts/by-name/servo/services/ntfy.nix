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
{
  sane.persist.sys.plaintext = [
    # not 100% necessary to persist this, but ntfy does keep a 12hr (by default) cache
    # for pushing notifications to users who become offline.
    # ACLs also live here.
    { user = "ntfy-sh"; group ="ntfy-sh"; path = "/var/lib/ntfy-sh"; }
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
    log-level = "trace";  # trace, debug, info (default), warn, error
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
    ${pkgs.ntfy-sh}/bin/ntfy access everyone "$topic" read-write
  '';

  sops.secrets."ntfy-sh-topic" = {
    mode = "0440";
    owner = config.users.users.ntfy-sh.name;
    group = config.users.users.ntfy-sh.name;
  };



  services.nginx.virtualHosts."ntfy.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2586";
      recommendedProxySettings = true; #< adds headers so ntfy logs include the real IP
      proxyWebsockets = true;  #< support websocket upgrades. without that, `ntfy sub` hangs silently
    };
  };
  sane.dns.zones."uninsane.org".inet.CNAME."ntfy" = "native";
}
