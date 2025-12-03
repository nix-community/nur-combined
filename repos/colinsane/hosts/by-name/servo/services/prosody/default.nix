# example configs:
# - official: <https://prosody.im/doc/example_config>
# - nixos: <https://github.com/kittywitch/nixfiles/blob/main/services/prosody.nix>
# config options:
# - <https://prosody.im/doc/configure>
#
# modules:
# - main: <https://prosody.im/doc/modules>
# - community: <https://modules.prosody.im/index.html>
#
# debugging:
# - logging:
#   - enable `stanza_debug` module
#   - enable `log.debug = "*syslog"` in extraConfig
# - interactive:
#   - `telnet localhost 5582` (this is equal to `prosodyctl shell` -- but doesn't hang)
#     - `watch:stanzas(target_spec, filter)` -> to log stanzas, for version > 0.12
#   - console docs: <https://prosody.im/doc/console>
#   - can modify/inspect arbitrary internals (lua) by prefixing line with `> `
#     - e.g. `> _G` to print all globals
#
# sanity checks:
# - `sudo -u prosody -g prosody prosodyctl check connectivity`
# - `sudo -u prosody -g prosody prosodyctl check turn`
# - `sudo -u prosody -g prosody prosodyctl check turn -v --ping=stun.conversations.im`
#   - checks that my stun/turn server is usable by clients of conversations.im (?)
# - `sudo -u prosody -g prosody prosodyctl check`  (dns, config, certs)
#
#
# create users with:
# - `sudo -u prosody prosodyctl adduser colin@uninsane.org`
#
#
# federation/support matrix:
# - nixnet.services (runs ejabberd):
#   - WORKS: sending and receiving PMs and calls (2023/10/15)
#     - N.B.: it didn't originally work; was solved by disabling the lua-unbound DNS option & forcing the system/local resolver
# - cheogram (XMPP <-> SMS gateway):
#   - WORKS: sending and receiving PMs, images (2023/10/15)
#   - PARTIAL: calls (xmpp -> tel works; tel -> xmpp fails)
#     - maybe i need to setup stun/turn
#
# TODO:
# - MIGRATE TO NIXOS MODULE OPTIONS:
#   - `services.prosody.ssl.`...
#   - `services.prosody.log`
#   - this decreases likelihood of breakage during future upgrades
# - enable push notifications (mod_cloud_notify)
# - optimize coturn (e.g. move off of the VPN!)
# - ensure muc is working
# - enable file uploads
#   - "upload.xmpp.uninsane.org:http_upload: URL: <https://upload.xmpp.uninsane.org:5281/upload> - Ensure this can be reached by users"
# - disable or fix bosh (jabber over http):
#   - "certmanager: No certificate/key found for client_https port 0"

{ config, lib, pkgs, ... }:

let
  # enables very verbose logging
  enableDebug = false;
in
{
  sane.persist.sys.byStore.private = [
    # TODO: mode?
    { user = "prosody"; group = "prosody"; path = "/var/lib/prosody"; method = "bind"; }
  ];
  sane.ports.ports."5000" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-xmpp-prosody-fileshare-proxy65";
  };
  sane.ports.ports."5222" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-xmpp-client-to-server";
  };
  sane.ports.ports."5223" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-xmpps-client-to-server";  # XMPP over TLS
  };
  sane.ports.ports."5269" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    description = "colin-xmpp-server-to-server";
  };
  sane.ports.ports."5270" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    description = "colin-xmpps-server-to-server";  # XMPP over TLS
  };
  sane.ports.ports."5280" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-xmpp-bosh";
  };
  sane.ports.ports."5281" = {
    protocol = [ "tcp" ];
    visibleTo.doof = true;
    visibleTo.lan = true;
    description = "colin-xmpp-prosody-https";  # necessary?
  };

  users.users.prosody.extraGroups = [
    "nginx"  # provide access to certs
    "ntfy-sh"  # access to secret ntfy topic
    "turnserver"  # to access the coturn shared secret
  ];

  security.acme.certs."uninsane.org".extraDomainNames = [
    "xmpp.uninsane.org"
    "conference.xmpp.uninsane.org"
    "upload.xmpp.uninsane.org"
  ];

  # exists so the XMPP server's cert can obtain altNames for all its resources
  services.nginx.virtualHosts."xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };
  services.nginx.virtualHosts."conference.xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };
  services.nginx.virtualHosts."upload.xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };

  sane.dns.zones."uninsane.org".inet = {
    # XXX: SRV records have to point to something with a A/AAAA record; no CNAMEs
    A."xmpp" =                "%ANATIVE%";
    CNAME."conference.xmpp" = "xmpp";
    CNAME."upload.xmpp" =     "xmpp";

    # _Service._Proto.Name    TTL Class SRV    Priority Weight Port Target
    # - <https://xmpp.org/extensions/xep-0368.html>
    # something's requesting the SRV records for conference.xmpp, so let's include it
    # nothing seems to request XMPP SRVs for the other records (except @)
    # lower numerical priority field tells clients to prefer this method
    SRV."_xmpps-client._tcp.conference.xmpp" =       "3 50 5223 xmpp";
    SRV."_xmpps-server._tcp.conference.xmpp" =       "3 50 5270 xmpp";
    SRV."_xmpp-client._tcp.conference.xmpp" =        "5 50 5222 xmpp";
    SRV."_xmpp-server._tcp.conference.xmpp" =        "5 50 5269 xmpp";

    SRV."_xmpps-client._tcp" =                "3 50 5223 xmpp";
    SRV."_xmpps-server._tcp" =                "3 50 5270 xmpp";
    SRV."_xmpp-client._tcp" =                 "5 50 5222 xmpp";
    SRV."_xmpp-server._tcp" =                 "5 50 5269 xmpp";
  };

  # help Prosody find its certificates.
  # pointing it to /var/lib/acme doesn't quite work because it expects the private key
  # to be named `privkey.pem` instead of acme's `key.pem`
  # <https://prosody.im/doc/certificates#automatic_location>
  environment.etc."prosody/certs/uninsane.org/fullchain.pem".source = "/var/lib/acme/uninsane.org/fullchain.pem";
  environment.etc."prosody/certs/uninsane.org/privkey.pem".source = "/var/lib/acme/uninsane.org/key.pem";

  services.prosody = {
    enable = true;
    package = pkgs.prosody.override {
      # XXX(2023/10/15): build without lua-unbound support.
      # this forces Prosody to fall back to the default Lua DNS resolver, which seems more reliable.
      # fixes errors like "unbound.queryXYZUV: Resolver error: out of memory"
      # related: <https://issues.prosody.im/1737#comment-11>
      lua.withPackages = selector: pkgs.lua.withPackages (p:
        selector (p // { luaunbound = null; })
      );
      # withCommunityModules = [ "turncredentials" ];
    };
    admins = [ "colin@uninsane.org" ];
    # allowRegistration = false;  # defaults to false

    muc = [
      {
        domain = "conference.xmpp.uninsane.org";
      }
    ];
    httpFileShare.domain = "upload.xmpp.uninsane.org";

    virtualHosts = {
      # "Prosody requires at least one enabled VirtualHost to function. You can
      # safely remove or disable 'localhost' once you have added another."
      # localhost = {
      #   domain = "localhost";
      #   enabled = true;
      # };
      "xmpp.uninsane.org" = {
        domain = "uninsane.org";
        enabled = true;
      };
    };

    ## modules:
    # these are enabled by default, via <repo:nixos/nixpkgs:/pkgs/servers/xmpp/prosody/default.nix>
    # - cloud_notify
    # - http_upload
    # - vcard_muc
    # these are enabled by the module defaults (services.prosody.modules.<foo>)
    # - admin_adhoc
    # - blocklist
    # - bookmarks
    # - carbons
    # - cloud_notify
    # - csi
    # - dialback
    # - disco
    # - http_files
    # - mam
    # - pep
    # - ping
    # - private
    #   - XEP-0049: let clients store arbitrary (private) data on the server
    # - proxy65
    #   - XEP-0065: allow server to proxy file transfers between two clients who are behind NAT
    # - register
    # - roster
    # - saslauth
    # - smacks
    # - time
    # - tls
    # - uptime
    # - vcard_legacy
    # - version

    extraPluginPaths = [ ./modules ];

    extraModules = [
      # admin_shell: allows `prosodyctl shell` to work
      # see: <https://prosody.im/doc/modules/mod_admin_shell>
      # see: <https://prosody.im/doc/console>
      "admin_shell"
      "admin_telnet"  #< needed by admin_shell
      # lastactivity: XEP-0012: allow users to query how long another user has been idle for
      # - not sure why i enabled this; think it was in someone's config i referenced
      "lastactivity"
      # allows prosody to share TURN/STUN secrets with XMPP clients to provide them access to the coturn server.
      # see: <https://prosody.im/doc/coturn>
      "turn_external"
      # legacy coturn integration
      # see: <https://modules.prosody.im/mod_turncredentials.html>
      # "turncredentials"
    ] ++ lib.optionals config.services.ntfy-sh.enable [
      "sane_ntfy"
    ] ++ lib.optionals enableDebug [
      "stanza_debug"  #< logs EVERY stanza as debug: <https://prosody.im/doc/modules/mod_stanza_debug>
    ];

    extraConfig = ''
      local function readAll(file)
        local f = Lua.assert(Lua.io.open(file, "rb"))
        local content = f:read("*all")
        f:close()
        -- remove trailing newline
        return Lua.string.gsub(content, "%s+", "")
      end

      -- logging docs:
      -- - <https://prosody.im/doc/logging>
      -- - <https://prosody.im/doc/advanced_logging>
      -- levels: debug, info, warn, error
      log = {
        ${if enableDebug then "debug" else "info"} = "*syslog";
      }

      -- see: <https://prosody.im/doc/certificates#automatic_location>
      -- try to solve: "certmanager: Error indexing certificate directory /run/prosody/certs: cannot open /run/prosody/certs: No such file or directory"
      -- only, this doesn't work because prosody doesn't like acme's naming scheme
      -- certificates = "/var/lib/acme/uninsane.org"
      -- instead, point to /etc/prosody/certs and configure symlinks into this dir (see nix config)
      certificates = "/etc/prosody/certs"

      c2s_direct_tls_ports = { 5223 }
      s2s_direct_tls_ports = { 5270 }

      turn_external_host = "turn.uninsane.org"
      turn_external_secret = readAll("/run/secrets/coturn_shared_secret")
      -- turn_external_user = "prosody"

      -- legacy mod_turncredentials integration
      -- turncredentials_host = "turn.uninsane.org"
      -- turncredentials_secret = readAll("/run/secrets/coturn_shared_secret")

      -- s2s_require_encryption = true
      -- c2s_require_encryption = true
    '' + lib.optionalString config.services.ntfy-sh.enable ''
      ntfy_binary = "${lib.getExe' pkgs.ntfy-sh "ntfy"}"
      ntfy_topic = readAll("/run/secrets/ntfy-sh-topic")
    '';
    checkConfig = false;  # secrets aren't available at build time
  };

  systemd.services.prosody = {
    # hardening (systemd-analyze security prosody)
    serviceConfig.LockPersonality = true;
    serviceConfig.NoNewPrivileges = true;
    serviceConfig.PrivateUsers = true;
    serviceConfig.ProcSubset = "pid";
    serviceConfig.ProtectClock = true;
    serviceConfig.ProtectKernelLogs = true;
    serviceConfig.ProtectProc = "invisible";
    serviceConfig.ProtectSystem = "strict";
    serviceConfig.RemoveIPC = true;
    serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    serviceConfig.SystemCallArchitectures = "native";
    serviceConfig.SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
  };
}
