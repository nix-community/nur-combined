# config docs:
# - <https://github.com/matrix-org/matrix-appservice-irc/blob/develop/config.sample.yaml>
# TODO: /quit message for bridged users reveals to IRC users that i'm using a bridge;
#       probably want to remove that.
{ config, lib, ... }:

let
  ircServer = { name, additionalAddresses ? [], sasl ? true }: let
    lowerName = lib.toLower name;
  in {
    # XXX sasl: appservice doesn't support NickServ identification (only SASL, or PASS if sasl = false)
    inherit name additionalAddresses sasl;
    port = 6697;
    ssl = true;
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

  sane.persist.sys.plaintext = [
    # TODO: mode?
    { user = "matrix-appservice-irc"; group = "matrix-appservice-irc"; directory = "/var/lib/matrix-appservice-irc"; }
  ];

  services.matrix-synapse.settings.app_service_config_files = [
    "/var/lib/matrix-appservice-irc/registration.yml"  # auto-created by irc appservice
  ];

  # Rizon supports CertFP for auth: https://wiki.rizon.net/index.php?title=CertFP
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
      servers = {
        "irc.rizon.net" = ircServer { name = "Rizon"; };
        "irc.myanonamouse.net" = ircServer {
          name = "MyAnonamouse";
          additionalAddresses = [ "irc2.myanonamouse.net" ];
          sasl = false;
        };
      };
    };
  };
}
