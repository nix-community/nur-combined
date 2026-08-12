{ config, lib, pkgs, ... }:

let
  cfg = config.services.tunnet;

  tomlFormat = pkgs.formats.toml { };
  configFile = tomlFormat.generate "tunnet.toml" cfg.settings;

  stateDir = "/var/lib/tunnet";
  runtimeDir = "/run/tunnet";

  # Assemble the tunnetd command line from the typed options plus any escape-hatch
  # extra arguments. false/null-valued flags are dropped by toCommandLineGNU.
  argv = lib.cli.toCommandLineGNU { } {
    ifname = cfg.interface;
    poll-secs = cfg.pollSeconds;
    metrics-bind = cfg.metricsBind;
    disable-gossip = cfg.disableGossip;
    no-mdns = cfg.noMdns;
    keep-alive = cfg.keepAlive;
    recorder = cfg.recorder;
  } ++ cfg.extraArgs;
in
{
  options.services.tunnet = {
    enable = lib.mkEnableOption "the Tunnet mesh agent (tunnetd)" // {
      description = ''
        Whether to enable the Tunnet mesh agent (tunnetd).

        This only supervises the daemon; the node still has to be enrolled once, which
        writes its identity into `${stateDir}`:

        ```
        sudo tunnet enroll --control-url https://control.example --token <TOKEN>
        sudo systemctl restart tunnet
        ```

        Do not use `tunnet service install|start|stop` on NixOS: those write
        /etc/systemd/system/tunnet.service and call `systemctl enable` behind this
        module's back. Use `systemctl {start,stop,restart} tunnet` instead.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/tunnet { };
      defaultText = lib.literalExpression "pkgs.tunnet";
      description = "The tunnet package to use.";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "tunnet0";
      description = "Name of the TUN interface the agent creates (tunnetd --ifname).";
    };

    pollSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 30;
      description = "How often to poll the control plane for changes (tunnetd --poll-secs).";
    };

    metricsBind = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:9100";
      description = "Address the Prometheus metrics endpoint listens on (tunnetd --metrics-bind).";
    };

    disableGossip = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Disable the gossip protocol used for real-time peer status, leaving only control
        plane polling (tunnetd --disable-gossip).
      '';
    };

    noMdns = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable mDNS-based local peer discovery (tunnetd --no-mdns).";
    };

    keepAlive = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Keep peer connections warm instead of letting them go idle (tunnetd --keep-alive).";
    };

    recorder = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable SSH session recording (tunnetd --recorder).";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/tunnet.env";
      description = ''
        Path to an environment file read by the service, for secrets that must not end up
        in the Nix store (for example `TUNNET_ENROLL_TOKEN=` or `TUNNET_LICENSE=`).
      '';
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          node.hostname = "web-01";
          logging.level = "debug";
        }
      '';
      description = ''
        Agent settings written to `${stateDir}/tunnet.toml` when that file does not exist
        yet. Only the keys set here override the organisation policy pushed by the control
        plane.

        The agent rewrites this file itself (`tunnet enroll`, `tunnet route add`, …), so it
        is copied rather than symlinked and is never overwritten once present; remove
        `${stateDir}/tunnet.toml` to pick up changes made here.

        `update.enabled` is forced to false: `tunnet update` replaces its own binary, which
        cannot work from the read-only Nix store. Update the package instead.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--no-encrypt-state" ];
      description = "Extra command-line arguments passed verbatim to tunnetd.";
    };
  };

  config = lib.mkIf cfg.enable {
    # `tunnet` is the user-facing half of the pair and is needed to enroll the node.
    environment.systemPackages = [ cfg.package ];

    boot.kernelModules = [ "tun" ];

    services.tunnet.settings.update.enabled = lib.mkDefault false;

    systemd.services.tunnet = {
      description = "Tunnet mesh agent";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # tunnetd shells out to `ip route` for subnet routes and exit nodes.
      path = [ pkgs.iproute2 ];

      environment = {
        TUNNET_STATE_DIR = stateDir;
        TUNNET_RUNTIME_DIR = runtimeDir;
        TUNNET_SERVICE_MODE = "1";
      };

      # Seed the config only when absent, so agent-written keys survive a restart.
      preStart = ''
        if [ ! -e ${stateDir}/tunnet.toml ]; then
          install -m600 ${configFile} ${stateDir}/tunnet.toml
        fi
      '';

      serviceConfig = {
        # tunnetd signals readiness with sd_notify and reloads on SIGHUP.
        Type = "notify-reload";
        ExecStart = "${cfg.package}/bin/tunnetd ${lib.escapeShellArgs argv}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = 2;
        KillMode = "mixed";
        TimeoutStartSec = 30;
        TimeoutStopSec = 30;
        StateDirectory = "tunnet";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "tunnet";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        # Runs as root on purpose, and deliberately unconfined: the agent creates the TUN
        # device, rewrites routes, writes /etc/systemd/resolved.conf.d for PeerDNS (then
        # restarts systemd-resolved) and toggles ip_forward when it acts as a subnet
        # gateway. ProtectSystem/DynamicUser would break all of that.
      };
    };
  };
}
