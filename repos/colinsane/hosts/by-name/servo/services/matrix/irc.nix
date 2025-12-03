# config docs:
# - <https://github.com/matrix-org/matrix-appservice-irc/blob/develop/config.sample.yaml>
{ lib, ... }:

let
  ircServer = { name, additionalAddresses ? [], ssl ? true, sasl ? true, port ? if ssl then 6697 else 6667 }: let
    lowerName = lib.toLower name;
  in {
    # XXX sasl: appservice doesn't support NickServ identification (only SASL, or PASS if sasl = false)
    inherit additionalAddresses name port sasl ssl;
    botConfig = {
      # bot has no presence in IRC channel; only real Matrix users
      enabled = false;
      # this is the IRC username/nickname *of the bot* (not visible in channels): not of the end-user.
      # the irc username/nick of a mapped Matrix user is determined further down in `ircClients` section.
      # if `enabled` is false, then this name probably never shows up on the IRC side (?)
      nick = "uninsane";
      username = "uninsane";
      joinChannelsIfNoUsers = false;
    };
    dynamicChannels = {
      enabled = true;
      aliasTemplate = "#irc_${lowerName}_$CHANNEL";
      published = false;  # false => irc rooms aren't listed in homeserver public rooms list
      federate = false;  # false => Matrix users from other homeservers can't join IRC channels
    };
    ircClients = {
      nickTemplate = "$LOCALPARTsane";  # @colin:uninsane.org (Matrix) -> colinsane (IRC)
      realnameFormat = "reverse-mxid";  # @colin:uninsane.org (Matrix) -> org.uninsane:colin (IRC)
      # realnameFormat = "localpart";  # @colin:uninsane.org (Matrix) -> colin (IRC)  -- but requires the mxid patch below
      # by default, Matrix will convert messages greater than (3) lines into a pastebin-like URL to send to IRC.
      lineLimit = 20;
      # Rizon in particular allows only 4 connections from one IP before a 30min ban.
      # that's effectively reduced to 2 during a netsplit, or maybe during a restart.
      #   - https://wiki.rizon.net/index.php?title=Connection/Session_Limit_Exemptions
      # especially, misconfigurations elsewhere in this config may cause hundreds of connections
      # so this is a safeguard.
      maxClients = 2;
      # don't have the bridge disconnect me from IRC when idle.
      idleTimeout = 0;
      concurrentReconnectLimit = 2;
      reconnectIntervalMs = 60000;
      kickOn = {
        # remove Matrix user from room when...
        channelJoinFailure = false;
        ircConnectionFailure = false;
        userQuit = true;
      };
    };
    matrixClients = {
      userTemplate = "@irc_${lowerName}_$NICK";  # the :uninsane.org part is appended automatically
    };

    # this will let this user message the appservice with `!join #<IRCChannel>` and the rest "Just Works"
    "@colin:uninsane.org" = "admin";

    membershipLists = {
      enabled = true;
      global = {
        ircToMatrix = {
          initial = true;
          incremental = true;
          requireMatrixJoined = false;
        };
        matrixToIrc = {
          initial = true;
          incremental = true;
        };
      };
      ignoreIdleUsersOnStartup = {
        enabled = false;  # false => always bridge users, even if idle
      };
    };
    # sync room description?
    bridgeInfoState = {
      enabled = true;
      initial = true;
    };

    # for per-user IRC password:
    # - invite @irc_${lowerName}_NickServ:uninsane.org to a DM and type `help`  => register
    # - invite the matrix-appservice-irc user to a DM and type `!help`   => add PW to database
    # to validate that i'm authenticated on the IRC network, DM @irc_${lowerName}_NickServ:uninsane.org:
    # - send: `STATUS colinsane`
    # - response should be `3`: "user recognized as owner via password identification"
    # passwordEncryptionKeyPath = "/path/to/privkey";  # appservice will generate its own if unspecified
  };
in
{

  nixpkgs.overlays = [
    (next: prev: {
      matrix-appservice-irc = prev.matrix-appservice-irc.overrideAttrs (super: {
        patches = super.patches or [] ++ [
          ./irc-no-reveal-bridge.patch
          # ./irc-no-reveal-mxid.patch
        ];
      });
    })
  ];

  sane.persist.sys.byStore.private = [
    # TODO: mode?
    { user = "matrix-appservice-irc"; group = "matrix-appservice-irc"; path = "/var/lib/matrix-appservice-irc"; method = "bind"; }
  ];

  # XXX: matrix-appservice-irc PreStart tries to chgrp the registration.yml to matrix-synapse,
  # which requires matrix-appservice-irc to be of that group
  users.users.matrix-appservice-irc.extraGroups = [ "matrix-synapse" ];
  # weird race conditions around registration.yml mean we want matrix-synapse to be of matrix-appservice-irc group too.
  users.users.matrix-synapse.extraGroups = [ "matrix-appservice-irc" ];

  services.matrix-synapse.settings.app_service_config_files = [
    "/var/lib/matrix-appservice-irc/registration.yml"  # auto-created by irc appservice
  ];

  services.matrix-appservice-irc.enable = true;
  services.matrix-appservice-irc.registrationUrl = "http://127.0.0.1:8009";
  services.matrix-appservice-irc.settings = {
    homeserver = {
      url = "http://127.0.0.1:8008";
      dropMatrixMessagesAfterSecs = 300;
      domain = "uninsane.org";
      enablePresence = true;
      bindPort = 9999;
      bindHost = "127.0.0.1";
    };

    ircService = {
      logging.level = "warn";  # "error", "warn", "info", "debug"
      mediaProxy.publicUrl = "https://irc.matrix.uninsane.org/media";
      servers = {
        "irc.esper.net" = ircServer {
          name = "esper";
          sasl = false;
          # notable channels:
          # - #merveilles
        };
        "irc.libera.chat" = ircServer {
          name = "libera";
          sasl = false;
          # notable channels:
          # - #hare
          # - #mnt-reform
        };
        "irc.myanonamouse.net" = ircServer {
          name = "MyAnonamouse";
          additionalAddresses = [ "irc2.myanonamouse.net" ];
          sasl = false;
        };
        "irc.oftc.net" = ircServer {
          name = "oftc";
          sasl = false;
          # notable channels:
          # - #sxmo
          # - #sxmo-offtopic
          # supposedly also available at <irc://37lnq2veifl4kar7.onion:6667/> (unofficial)
        };
        "irc.rizon.net" = ircServer { name = "Rizon"; };
        # "irc.sdf.org" = ircServer {
        #   # XXX(2024-11-06): seems it can't connect. "matrix-appservice-irc: WARN:Provisioner Provisioner only handles text 'yes'/'y' (from BASHy2-EU on irc.sdf.org)"
        #   # use instead? <https://lemmy.sdf.org/c/sdfpubnix>
        #   name = "sdf";
        #   # sasl = false;
        #   # notable channels (see: <https://sdf.org/?tutorials/irc-channels>)
        #   # - #sdf
        # };
        "wigle.net" = ircServer {
          name = "WiGLE";
          ssl = false;
        };
      };
    };
  };

  systemd.services.matrix-appservice-irc.serviceConfig = {
    # XXX 2023/06/20: nixos specifies this + @aio and @memlock as forbidden
    # the service actively uses at least one of these, and both of them are fairly innocuous
    SystemCallFilter = lib.mkForce "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @setuid @swap";
  };

  services.nginx.virtualHosts."irc.matrix.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/media" = {
      proxyPass = "http://127.0.0.1:11111";
      recommendedProxySettings = true;
    };
  };

  sane.dns.zones."uninsane.org".inet = {
    CNAME."irc.matrix" = "native";
  };
}
