{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    optionalAttrs
    optionals
    ;

  cfg = config.services.msd-lite;

  xmlFormat = pkgs.formats.xml { };

  badgerfish = {
    msd = {
      log.level."#text" = toString cfg.logLevel;

      threadPool = {
        threadsCountMax."#text" = toString cfg.threadsCountMax;
        fBindToCPU."#text" = if cfg.bindToCPU then "yes" else "no";
      };

      HTTP = {
        bindList.bind = map (
          bind:
          (
            {
              address."#text" = bind.address;
            }
            // (optionalAttrs (bind.acceptFilter != null) {
              fAcceptFilter."#text" = if bind.acceptFilter then "y" else "n";
            })
          )
        ) cfg.http.bind;

        hostnameList.hostname = map (hostname: { "#text" = hostname; }) cfg.http.hostname;
      };

      hubProfileList.hubProfile = map (hub: {
        fDropSlowClients."#text" = if hub.dropSlowClients then "yes" else "no";
        fSocketHalfClosed."#text" = if hub.socketHalfClosed then "yes" else "no";
        fSocketTCPNoDelay."#text" = if hub.socketTCPNoDelay then "yes" else "no";
        fSocketTCPNoPush."#text" = if hub.socketTCPNoPush then "yes" else "no";
        precache."#text" = toString hub.precache;
        ringBufSize."#text" = toString hub.ringBufSize;

        skt = {
          sndBuf."#text" = toString hub.skt.sndBuf;
          sndLoWatermark."#text" = toString hub.skt.sndLoWatermark;
          congestionControl."#text" = hub.skt.congestionControl;
        };

        headersList.header = map (h: { "#text" = h; }) hub.headers;
      }) (if cfg.hubs != [ ] then cfg.hubs else [ cfg.hub ]);

      sourceProfileList.sourceProfile = map (source: {
        skt = {
          rcvBuf."#text" = toString source.skt.rcvBuf;
          rcvLoWatermark."#text" = toString source.skt.rcvLoWatermark;
          rcvTimeout."#text" = toString source.skt.rcvTimeout;
        };

        multicast = {
          ifName."#text" = source.multicast.ifName;
          rejoinTime."#text" = toString source.multicast.rejoinTime;
        };
      }) (if cfg.sources != [ ] then cfg.sources else [ cfg.source ]);

    };
  };

  configFile = xmlFormat.generate "msd_lite.conf" badgerfish;

  hubType = types.submodule (
    { ... }:
    {
      options = {
        dropSlowClients = mkOption {
          type = types.bool;
          default = false;
          description = "Disconnect slow clients (fDropSlowClients).";
        };
        socketHalfClosed = mkOption {
          type = types.bool;
          default = false;
          description = "Enable shutdown(SHUT_RD) for clients (fSocketHalfClosed).";
        };
        socketTCPNoDelay = mkOption {
          type = types.bool;
          default = true;
          description = "Enable TCP_NODELAY for clients (fSocketTCPNoDelay).";
        };
        socketTCPNoPush = mkOption {
          type = types.bool;
          default = true;
          description = "Enable TCP_NOPUSH/TCP_CORK for clients (fSocketTCPNoPush).";
        };
        precache = mkOption {
          type = types.ints.positive;
          default = 4096;
          description = "Pre-cache size in KB; may be overwritten by user request args.";
        };
        ringBufSize = mkOption {
          type = types.ints.positive;
          default = 1024;
          description = "Stream receive ring buffer size in KB; must be multiple of sndBlockSize.";
        };

        skt = mkOption {
          type = types.submodule (
            { ... }:
            {
              options = {
                sndBuf = mkOption {
                  type = types.ints.positive;
                  default = 512;
                  description = "Max send block size in KB for client sockets; must be > sndBlockSize.";
                };
                sndLoWatermark = mkOption {
                  type = types.ints.positive;
                  default = 64;
                  description = "Send block size in KB; must be multiple of 4.";
                };
                congestionControl = mkOption {
                  type = types.str;
                  default = "htcp";
                  description = "TCP_CONGESTION; overwrites cc from HTTP args/server settings/OS default.";
                };
              };
            }
          );
          default = { };
          description = "Hub profile socket settings.";
        };

        headers = mkOption {
          type = types.listOf types.str;
          default = [
            "Pragma: no-cache"
            "Content-Type: video/mpeg"
            "ContentFeatures.DLNA.ORG: DLNA.ORG_OP=01;DLNA.ORG_CI=0;DLNA.ORG_FLAGS=01700000000000000000000000000000"
            "TransferMode.DLNA.ORG: Streaming"
          ];
          description = "Custom HTTP headers sent before stream.";
        };
      };
    }
  );

  sourceType = types.submodule (
    { ... }:
    {
      options = {
        skt = mkOption {
          type = types.submodule (
            { ... }:
            {
              options = {
                rcvBuf = mkOption {
                  type = types.ints.positive;
                  default = 512;
                  description = "Multicast receive socket buffer size in KB.";
                };
                rcvLoWatermark = mkOption {
                  type = types.ints.positive;
                  default = 48;
                  description = "Actual cli_snd_block_min if polling is off; SO_RCVLOWAT not respected by select/poll on Linux.";
                };
                rcvTimeout = mkOption {
                  type = types.ints.positive;
                  default = 2;
                  description = "STATUS: multicast receive timeout in seconds.";
                };
              };
            }
          );
          default = { };
          description = "Source profile socket settings.";
        };

        multicast = mkOption {
          type = types.submodule (
            { ... }:
            {
              options = {
                ifName = mkOption {
                  type = types.str;
                  default = "vlan777";
                  description = "Network interface name for multicast receive.";
                };
                rejoinTime = mkOption {
                  type = types.ints.unsigned;
                  default = 0;
                  description = "Do IGMP/MLD leave+join every X seconds (0 disables periodic rejoin).";
                };
              };
            }
          );
          default = { };
          description = "Multicast settings for multicast-udp and multicast-udp-rtp.";
        };
      };
    }
  );

in
{
  options.services.msd-lite = {
    enable = mkEnableOption "msd-lite streaming daemon/service.";

    logLevel = mkOption {
      type = types.ints.between 0 7;
      default = 6;
      description = ''
        Syslog severity level for msd-lite logging.
        Range: 0=emerg .. 7=debug.
      '';
      example = 7;
    };

    threadsCountMax = mkOption {
      type = types.ints.unsigned;
      default = 1;
      description = ''
        Maximum thread count for msd-lite thread pool.
        0 means auto.
      '';
      example = 0;
    };

    bindToCPU = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to bind worker threads to CPUs (fBindToCPU).";
      example = false;
    };

    http = {
      bind = mkOption {
        type = types.listOf (
          types.submodule (
            { ... }:
            {
              options = {
                address = mkOption {
                  type = types.str;
                  description = "HTTP server binding address, e.g. 0.0.0.0:7088 or [::]:7088.";
                  example = "0.0.0.0:7088";
                };

                acceptFilter = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = ''
                    Whether to emit <fAcceptFilter>y/n</fAcceptFilter> for this binding.
                    Set to null to omit the tag (same behavior as msd-lite example for the second bind).
                  '';
                  example = null;
                };
              };
            }
          )
        );
        default = [
          {
            address = "0.0.0.0:7088";
            acceptFilter = true;
          }
          {
            address = "[::]:7088";
            acceptFilter = null;
          }
        ];
        description = "HTTP server bindings.";
      };

      hostname = mkOption {
        type = types.listOf types.str;
        default = [ "*" ];
        description = "Host names accepted for all HTTP bindings.";
        example = [
          "example.com"
          "*"
        ];
      };
    };
    hub = mkOption {
      type = types.nullOr hubType;
      default = { };
      description = "Single hub profile template (single).";
    };

    hubs = mkOption {
      type = types.listOf hubType;
      default = [ ];
      description = "List of hub profile templates (list).";
    };

    source = mkOption {
      type = types.nullOr sourceType;
      default = { };
      description = "Single source profile template (single).";
    };

    sources = mkOption {
      type = types.listOf sourceType;
      default = [ ];
      description = "List of source profile templates (sourceProfile).";
    };

    package = lib.options.mkPackageOption pkgs "msd-lite" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ];

    systemd.services.msd-lite = {
      description = "Multi stream daemon - lightweight daemon for streaming media";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} -c ${configFile}";
        Restart = "on-failure";
        DynamicUser = true;
        LimitNOFILE = 32768;
      };
    };

    # environment = {
    #   systemPackages = [ cfg.package ];
    # };
  };
}
