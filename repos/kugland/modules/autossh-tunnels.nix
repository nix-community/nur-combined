{ pkgs
, lib
, config
, ...
}:
with lib;
let

  cfg = config.services.autosshTunnels;

  mkTunnel = tunnel:
    "-L " + (if tunnel.localAddress != null then "${tunnel.localAddress}:" else "") + "${toString tunnel.localPort}" + ":" + (if tunnel.remoteAddress != null then "${tunnel.remoteAddress}:" else "127.0.0.1:") + "${toString tunnel.remotePort}";

in
{
  options = {
    services.autosshTunnels = {
      sessions = lib.mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            user = lib.mkOption {
              type = types.str;
              description = "User to connect as";
            };
            host = lib.mkOption {
              type = types.str;
              description = "Remote host to connect to";
            };
            port = lib.mkOption {
              type = types.ints.u16;
              description = "Remote port to connect to";
              default = 22;
            };
            secretKey = lib.mkOption {
              type = types.str;
              description = "Path to the private key to use";
            };
            tunnels = lib.mkOption {
              type = types.listOf (types.submodule {
                options = {
                  localAddress = lib.mkOption {
                    type = types.nullOr types.str;
                    description = "Local address to bind to";
                    default = null;
                  };
                  localPort = lib.mkOption {
                    type = types.int;
                    description = "Local port to bind to";
                  };
                  remoteAddress = lib.mkOption {
                    type = types.nullOr types.str;
                    description = "Remote address to forward to";
                    default = null;
                  };
                  remotePort = lib.mkOption {
                    type = types.int;
                    description = "Remote port to forward to";
                  };
                };
              });
              default = [ ];
            };
          };
        });
        default = { };
        example = {
          somehost = {
            user = "user";
            host = "somehost.example.com";
            port = 2222;
            secretKey = "/etc/secrets/my-secret-key";
            tunnels = [
              {
                localPort = 8080;
                remotePort = 3000;
              }
              {
                localAddress = "127.1.1.1";
                localPort = 8080;
                remotePort = 3001;
              }
            ];
          };
        };
      };
    };
  };

  config = lib.mkIf ((builtins.length (builtins.attrNames cfg.sessions)) > 0) {
    users = {
      users.autossh = {
        isSystemUser = true;
        description = "autossh";
        group = "autossh";
        shell = "${pkgs.shadow}/bin/nologin";
      };
      groups.autossh = { };
    };
    services.autossh.sessions = map
      (name:
        let session = cfg.sessions.${name}; in
        {
          inherit name;
          user = "autossh";
          monitoringPort = 0;
          extraArguments = lib.concatStringsSep " " ([
            "-N"
            "-o Port=${toString session.port}"
            "-o ControlMaster=no"
            "-o Compression=no"
            "-o ExitOnForwardFailure=yes"
            "-o TCPKeepAlive=yes"
            "-o ServerAliveInterval=60"
            "-i ${session.secretKey}"
            "${session.user}@${session.host}"
          ] ++ (map mkTunnel session.tunnels));
        }
      )
      (builtins.attrNames cfg.sessions);

    systemd.services = builtins.listToAttrs (map
      (name:
        {
          name = "autossh-${name}";
          value = {
            serviceConfig = {
              Environment = [ "LD_PRELOAD=${pkgs.graphene-hardened-malloc}/lib/libhardened_malloc.so" ];
              CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
              CPUQuota = "10%";
              DevicePolicy = "closed";
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              NoNewPrivileges = true;
              PrivateDevices = true;
              PrivateIPC = true;
              PrivateTmp = true;
              PrivateUsers = true;
              ProcSubset = "pid";
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectProc = "invisible";
              RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" "AF_INET" ];
              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
            };
          };
        })
      (builtins.attrNames cfg.sessions));
  };
}
