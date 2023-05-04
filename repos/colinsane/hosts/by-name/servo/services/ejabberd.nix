# docs:
# - <https://docs.ejabberd.im/admin/configuration/basic>
# example configs:
# - <https://github.com/vkleen/machines/blob/138a2586ce185d7cf201d4e1fe898c83c4af52eb/hosts/europium/ejabberd.nix>
# - <https://github.com/Mic92/stockholm/blob/675ef0088624c9de1cb531f318446316884a9d3d/tv/3modules/ejabberd/default.nix>
# - <https://github.com/buffet/tararice/blob/master/programs/ejabberd.nix>
#   - enables STUN and TURN
#   - only over UDP 3478, not firewall-forwarding any TURN port range
#   - uses stun_disco module (but with no options)
# - <https://github.com/leo60228/dotfiles/blob/39b3abba3009bdc31413d4757ca2f882a33eec8b/files/ejabberd.yml>
# - <https://github.com/Mic92/dotfiles/blob/ddf0f4821f554f7667fc803344657367c55fb9e6/nixos/eve/modules/ejabberd.nix>
# - <nixpkgs:nixos/tests/xmpp/ejabberd.nix>
# - 2013: <https://github.com/processone/ejabberd/blob/master/ejabberd.yml.example>
#
# compliance tests:
# - <https://compliance.conversations.im/server/uninsane.org/#xep0352>
{ config, lib, pkgs, ... }:

# XXX: avatar support works in MUCs but not DMs
# lib.mkIf false
{
  sane.persist.sys.plaintext = [
    { user = "ejabberd"; group = "ejabberd"; directory = "/var/lib/ejabberd"; }
  ];
  networking.firewall.allowedTCPPorts = [
    3478  # STUN/TURN
    5222  # XMPP  client -> server
    5223  # XMPPS client -> server (XMPP over TLS)
    5269  # XMPP  server -> server
    5270  # XMPPS server -> server (XMPP over TLS)
    5280  # bosh
    5281  # bosh (https) ??
    5349  # STUN/TURN (TLS)
    5443  # web services (file uploads, websockets, admin)
  ];
  networking.firewall.allowedUDPPorts = [
    3478  # STUN/TURN
  ];
  networking.firewall.allowedTCPPortRanges = [{
    from = 49152;  # TURN
    to = 49408;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 49152;  # TURN
    to = 49408;
  }];

  # provide access to certs
  # TODO: this should just be `acme`. then we also add nginx to the `acme` group.
  #   why is /var/lib/acme/* owned by `nginx` group??
  users.users.ejabberd.extraGroups = [ "nginx" ];

  security.acme.certs."uninsane.org".extraDomainNames = [
    "xmpp.uninsane.org"
    "muc.xmpp.uninsane.org"
    "pubsub.xmpp.uninsane.org"
    "upload.xmpp.uninsane.org"
    "vjid.xmpp.uninsane.org"
  ];

  # exists so the XMPP server's cert can obtain altNames for all its resources
  services.nginx.virtualHosts."xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };
  services.nginx.virtualHosts."muc.xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };
  services.nginx.virtualHosts."pubsub.xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };
  services.nginx.virtualHosts."upload.xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };
  services.nginx.virtualHosts."vjid.xmpp.uninsane.org" = {
    useACMEHost = "uninsane.org";
  };

  sane.services.trust-dns.zones."uninsane.org".inet = {
    # XXX: SRV records have to point to something with a A/AAAA record; no CNAMEs
    A."xmpp" =                "%NATIVE%";
    CNAME."muc.xmpp" =        "xmpp";
    CNAME."pubsub.xmpp" =     "xmpp";
    CNAME."upload.xmpp" =     "xmpp";
    CNAME."vjid.xmpp" =       "xmpp";

    # _Service._Proto.Name    TTL Class SRV    Priority Weight Port Target
    # - <https://xmpp.org/extensions/xep-0368.html>
    # something's requesting the SRV records for muc.xmpp, so let's include it
    # nothing seems to request XMPP SRVs for the other records (except @)
    # lower numerical priority field tells clients to prefer this method
    SRV."_xmpps-client._tcp.muc.xmpp" =       "3 50 5223 xmpp";
    SRV."_xmpps-server._tcp.muc.xmpp" =       "3 50 5270 xmpp";
    SRV."_xmpp-client._tcp.muc.xmpp" =        "5 50 5222 xmpp";
    SRV."_xmpp-server._tcp.muc.xmpp" =        "5 50 5269 xmpp";

    SRV."_xmpps-client._tcp" =                "3 50 5223 xmpp";
    SRV."_xmpps-server._tcp" =                "3 50 5270 xmpp";
    SRV."_xmpp-client._tcp" =                 "5 50 5222 xmpp";
    SRV."_xmpp-server._tcp" =                 "5 50 5269 xmpp";

    SRV."_stun._udp" =                        "5 50 3478 xmpp";
    SRV."_stun._tcp" =                        "5 50 3478 xmpp";
    SRV."_stuns._tcp" =                       "5 50 5349 xmpp";
    SRV."_turn._udp" =                        "5 50 3478 xmpp";
    SRV."_turn._tcp" =                        "5 50 3478 xmpp";
    SRV."_turns._tcp" =                       "5 50 5349 xmpp";
  };

  # TODO: allocate UIDs/GIDs ?
  services.ejabberd.enable = true;
  services.ejabberd.configFile = "/var/lib/ejabberd/ejabberd.yaml";
  systemd.services.ejabberd.preStart = let
    config-in = pkgs.writeTextFile {
      name = "ejabberd.yaml.in";
      text = ''
        hosts:
          - uninsane.org

        # none | emergency | alert | critical | error | warning | notice | info | debug
        loglevel: debug
        # loglevel: info
        # loglevel: notice

        acme:
          auto: false
        certfiles:
        - /var/lib/acme/uninsane.org/full.pem
        # ca_file: ${pkgs.cacert.unbundled}/etc/ssl/certs/
        # ca_file: ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

        pam_userinfotype: jid

        acl:
          admin:
            user:
              - "colin@uninsane.org"
          local:
            user_regexp: ""
          loopback:
            ip:
              - 127.0.0.0/8
              - ::1/128

        access_rules:
          local:
            allow: local
          c2s_access:
            allow: all
          announce:
            allow: admin
          configure:
            allow: admin
          muc_create:
            allow: local
          pubsub_createnode_access:
            allow: all
          trusted_network:
            allow: loopback

        # docs: <https://docs.ejabberd.im/admin/configuration/basic/#shaper-rules>
        shaper_rules:
          # setting this to above 1 may break outgoing messages
          # - maybe some servers rate limit? or just don't understand simultaneous connections?
          max_s2s_connections: 1
          max_user_sessions: 10
          max_user_offline_messages: 5000
          c2s_shaper:
            fast: all
          s2s_shaper:
            med: all

        # docs: <https://docs.ejabberd.im/admin/configuration/basic/#shapers>
        # this limits the bytes/sec.
        # for example, burst: 3_000_000 and rate: 100_000 means:
        # - each client has a BW budget that accumulates 100kB/sec and is capped at 3 MB
        shaper:
          fast: 1000000
          med:   500000
        #   fast:
        #     - rate:        1000000
        #     - burst_size: 10000000
        #   med:
        #     - rate:         500000
        #     - burst_size:  5000000

        # see: <https://docs.ejabberd.im/admin/configuration/listen/>
        # s2s_use_starttls: true
        s2s_use_starttls: optional
        # lessens 504: remote-server-timeout errors
        # see: <https://github.com/processone/ejabberd/issues/3105#issuecomment-562182967>
        negotiation_timeout: 60

        listen:
          -
            port: 5222
            module: ejabberd_c2s
            shaper: c2s_shaper
            starttls: true
            access: c2s_access
          -
            port: 5223
            module: ejabberd_c2s
            shaper: c2s_shaper
            tls: true
            access: c2s_access
          -
            port: 5269
            module: ejabberd_s2s_in
            shaper: s2s_shaper
          -
            port: 5270
            module: ejabberd_s2s_in
            shaper: s2s_shaper
            tls: true
          -
            port: 5443
            module: ejabberd_http
            tls: true
            request_handlers:
              /admin: ejabberd_web_admin  # TODO: ensure this actually works
              /api: mod_http_api  # ejabberd API endpoint (to control server)
              /bosh: mod_bosh
              /upload: mod_http_upload
              /ws: ejabberd_http_ws
              # /.well-known/host-meta: mod_host_meta
              # /.well-known/host-meta.json: mod_host_meta
          -
            # STUN+TURN TCP
            # note that the full port range should be forwarded ("not NAT'd")
            # `use_turn=true` enables both TURN *and* STUN
            port: 3478
            module: ejabberd_stun
            transport: tcp
            use_turn: true
            turn_min_port: 49152
            turn_max_port: 65535
            turn_ipv4_address: %NATIVE%
          -
            # STUN+TURN UDP
            port: 3478
            module: ejabberd_stun
            transport: udp
            use_turn: true
            turn_min_port: 49152
            turn_max_port: 65535
            turn_ipv4_address: %NATIVE%
          -
            # STUN+TURN TLS over TCP
            port: 5349
            module: ejabberd_stun
            transport: tcp
            tls: true
            certfile: /var/lib/acme/uninsane.org/full.pem
            use_turn: true
            turn_min_port: 49152
            turn_max_port: 65535
            turn_ipv4_address: %NATIVE%

        # TODO: enable mod_fail2ban
        # TODO(low): look into mod_http_fileserver for serving macros?
        modules:
          # mod_adhoc: {}
          # mod_announce:
          #   access: admin
          # allows users to set avatars in vCard
          # - <https://docs.ejabberd.im/admin/configuration/modules/#mod-avatar>
          mod_avatar: {}
          mod_caps: {}  # for mod_pubsub
          mod_carboncopy: {}  # allows multiple clients to receive a user's message
          # queues messages when recipient is offline, including PEP and presence messages.
          # compliance test suggests this be enabled
          mod_client_state: {}
          # mod_conversejs: TODO: enable once on 21.12
          # allows clients like Dino to discover where to upload files
          mod_disco:
            server_info:
              -
                modules: all
                name: abuse-addresses
                urls:
                  - "mailto:admin.xmpp@uninsane.org"
                  - "xmpp:colin@uninsane.org"
              -
                modules: all
                name: admin-addresses
                urls:
                  - "mailto:admin.xmpp@uninsane.org"
                  - "xmpp:colin@uninsane.org"
          mod_http_upload:
            host: upload.xmpp.uninsane.org
            hosts:
              - upload.xmpp.uninsane.org
            put_url: "https://@HOST@:5443/upload"
            dir_mode: "0750"
            file_mode: "0750"
            rm_on_unregister: false
          # allow discoverability of BOSH and websocket endpoints
          # TODO: enable once on ejabberd 22.05  (presently 21.04)
          # mod_host_meta: {}
          mod_jidprep: {}  # probably not needed: lets clients normalize jids
          mod_last: {}  # allow other users to know when i was last online
          mod_mam:
            # Mnesia is limited to 2GB, better to use an SQL backend
            # For small servers SQLite is a good fit and is very easy
            # to configure. Uncomment this when you have SQL configured:
            # db_type: sql
            assume_mam_usage: true
            default: always
          mod_muc:
            access:
              - allow
            access_admin:
              - allow: admin
            access_create: muc_create
            access_persistent: muc_create
            access_mam:
              - allow
            history_size: 100  # messages to show new participants
            host: muc.xmpp.uninsane.org
            hosts:
              - muc.xmpp.uninsane.org
            default_room_options:
              anonymous: false
              lang: en
              persistent: true
              mam: true
          mod_muc_admin: {}
          mod_offline:  # store messages for a user when they're offline (TODO: understand multi-client workflow?)
            access_max_user_messages: max_user_offline_messages
            store_groupchat: true
          mod_ping: {}
          mod_privacy: {}  # deprecated, but required for `ejabberctl export_piefxis`
          mod_private: {}  # allow local clients to persist arbitrary data on my server
          # push notifications to services integrated with e.g. Apple/Android.
          # default is for a maximum amount of PII to be withheld, since these push notifs
          # generally traverse 3rd party services. can opt to include message body, etc, though.
          mod_push: {}
          # i don't fully understand what this does, but it seems aimed at making push notifs more reliable.
          mod_push_keepalive: {}
          mod_roster:
            versioning: true
          # docs: <https://docs.ejabberd.im/admin/configuration/modules/#mod-s2s-dialback>
          # s2s dialback to verify inbound messages
          # unclear to what degree the XMPP network requires this
          mod_s2s_dialback: {}
          mod_shared_roster: {}  # creates groups for @all, @online, and anything manually administered?
          mod_stream_mgmt:
            resend_on_timeout: if_offline  # resend undelivered messages if the origin client is offline
          # fallback for when DNS-based STUN discovery is unsupported.
          # - see: <https://xmpp.org/extensions/xep-0215.html>
          # docs: <https://docs.ejabberd.im/admin/configuration/modules/#mod-stun-disco>
          # people say to just keep this defaulted (i guess ejabberd knows to return its `host` option of uninsane.org?)
          mod_stun_disco: {}
          # docs: <https://docs.ejabberd.im/admin/configuration/modules/#mod-vcard>
          mod_vcard:
            allow_return_all: true  # all users are discoverable (?)
            host: vjid.xmpp.uninsane.org
            hosts:
              - vjid.xmpp.uninsane.org
            search: true
          mod_vcard_xupdate: {}  # needed for avatars
          # docs: <https://docs.ejabberd.im/admin/configuration/modules/#mod-pubsub>
          mod_pubsub:  # needed for avatars
            access_createnode: pubsub_createnode_access
            host: pubsub.xmpp.uninsane.org
            hosts:
              - pubsub.xmpp.uninsane.org
            ignore_pep_from_offline: false
            last_item_cache: true
            plugins:
              - pep
              - flat
            force_node_config:
              # ensure client bookmarks are private
              storage:bookmarks:
                access_model: whitelist
              urn:xmpp:avatar:data:
                access_model: open
              urn:xmpp:avatar:metadata:
                access_model: open
          mod_version: {}
      '';
    };
    sed = "${pkgs.gnused}/bin/sed";
  in ''
    ip=$(cat '${config.sane.services.dyn-dns.ipPath}')
    # config is 444 (not 644), so we want to write out-of-place and then atomically move
    # TODO: factor this out into `sane-woop` helper?
    rm -f /var/lib/ejabberd/ejabberd.yaml.new
    ${sed} "s/%NATIVE%/$ip/" ${config-in} > /var/lib/ejabberd/ejabberd.yaml.new
    mv /var/lib/ejabberd/ejabberd.yaml{.new,}
  '';

  sane.services.dyn-dns.restartOnChange = [ "ejabberd.service" ];
}
