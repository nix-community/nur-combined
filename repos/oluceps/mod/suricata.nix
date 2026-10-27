{
  flake.modules.nixos.suricata =
    {
      config,
      lib,
      pkgs,
      utils,
      ...
    }:
    let
      cfg = config.services.suricata;
      interfaces = [
        "vm1"
        "eno1"
        "vxlan-mesh"
      ];
      publicMeshNodes = import ../lib/public-mesh-nodes.nix {
        inherit lib;
        nodes = config.data.node;
        hostName = config.networking.hostName;
      };
      publicMeshAddresses = lib.unique (lib.flatten (builtins.attrValues publicMeshNodes));
      systemctl = "${config.systemd.package}/bin/systemctl";
      yaml = pkgs.formats.yaml { };
      localRules = pkgs.writeText "suricata-local.rules" (builtins.readFile ./suricata/local.rules);
      capture = interface: {
        inherit interface;
        threads = 2;
        cluster-id =
          {
            vm1 = 91;
            eno1 = 92;
            vxlan-mesh = 93;
          }
          .${interface};
        cluster-type = "cluster_flow";
        defrag = true;
        use-mmap = true;
        tpacket-v3 = true;
        checksum-checks = "kernel";
      };
      configFile =
        interface:
        let
          settings =
            (lib.filterAttrsRecursive (_: value: value != null) cfg.settings)
            // {
              af-packet = [ (capture interface) ];
              default-log-dir = "/var/log/suricata/${interface}";
              vars = cfg.settings.vars // {
                address-groups = cfg.settings.vars.address-groups // {
                  PUBLIC_MESH_NET = "[${lib.concatStringsSep "," publicMeshAddresses}]";
                };
              };
              stats = (builtins.removeAttrs cfg.settings.stats [ "enable" ]) // {
                enabled = cfg.settings.stats.enable;
              };
              logging = (lib.filterAttrsRecursive (_: value: value != null) cfg.settings.logging) // {
                default-log-format = "%D: %S: %M";
                outputs = [ { console.enabled = true; } ];
              };
              unix-command = {
                enabled = true;
                filename = "/run/suricata-${interface}/command.socket";
              };
            }
            // lib.optionalAttrs (interface == "vxlan-mesh") {
              # The BPF snaplen must also cover reassembled packets above the VXLAN MTU.
              default-packet-size = 65568;
              # Include replies so TCP and application parsers see both directions.
              bpf-filter = lib.concatMapStringsSep " or " (addr: "host ${addr}") publicMeshAddresses;
            };
        in
        yaml.generate "suricata-${interface}.yaml" settings;
      instance =
        interface:
        let
          file = configFile interface;
          device = "${utils.escapeSystemdPath "/sys/subsystem/net/devices/${interface}"}.device";
        in
        {
          description = "Passive Suricata capture on ${interface}";
          wantedBy = [ "multi-user.target" ];
          wants = [ "suricata-update.service" ];
          bindsTo = [ device ];
          after = [
            device
            "suricata-update.service"
          ];
          startLimitIntervalSec = 0;
          serviceConfig = config.systemd.services.suricata.serviceConfig // {
            ExecStartPre = [
              "${pkgs.coreutils}/bin/test -s ${cfg.settings.default-rule-path}/suricata.rules"
              "!${cfg.package}/bin/suricata -c ${file} -l /var/log/suricata/${interface} -T --init-errors-fatal"
            ];
            ExecStart = "!${cfg.package}/bin/suricata -c ${file} -l /var/log/suricata/${interface} --af-packet=${interface} --init-errors-fatal";
            ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
            RestartSec = "10s";
            UMask = "0027";
            ReadOnlyPaths = [
              file
              cfg.settings.default-rule-path
            ];
            ReadWritePaths = [ "/var/log/suricata/${interface}" ];
            RuntimeDirectory = "suricata-${interface}";
            RuntimeDirectoryMode = "0750";
          };
        };
    in
    {
      services.suricata = {
        enable = true;
        enabledSources = [ "et/open" ];
        configFile = configFile "eno1";
        # The native reload unit targets the disabled, single-instance service.
        reloadOnRulesetUpdate = false;
        settings = {
          af-packet = map capture interfaces;
          host-mode = "sniffer-only";
          vars.address-groups = {
            HOME_NET = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,fc00::/7,fec0::/10]";
            # Inspect local and external peers on this router and service host.
            EXTERNAL_NET = "any";
          };
          rule-files = [
            "suricata.rules"
            (toString localRules)
          ];
          # Host and TAP capture can include packets before checksum offload.
          stream.checksum-validation = false;
          stats = {
            enable = true;
            interval = "30";
          };
          logging.outputs.file.enable = false;
          outputs = [
            {
              eve-log = {
                enabled = true;
                filetype = "regular";
                filename = "eve.json";
                filemode = "640";
                community-id = true;
                types = [
                  "alert"
                  "flow"
                  "dns"
                  {
                    tls = {
                      extended = true;
                      session-resumption = true;
                    };
                  }
                  {
                    stats = {
                      totals = true;
                      threads = false;
                    };
                  }
                ];
              };
            }
          ];
          app-layer.protocols =
            (lib.genAttrs
              [
                "http"
                "http2"
                "tls"
                "ssh"
                "smtp"
                "ftp"
                "smb"
                "dcerpc"
                "nfs"
                "tftp"
                "ntp"
                "quic"
                "dhcp"
                "mqtt"
                "modbus"
                "krb5"
                "snmp"
                "ike"
                "rfb"
                "telnet"
                "bittorrent-dht"
                "pop3"
                "doh2"
              ]
              (_: {
                enabled = "yes";
              })
            )
            // {
              dns = {
                enabled = "yes";
                tcp.enabled = true;
                udp.enabled = true;
              };
              imap.enabled = "detection-only";
            };
        };
      };

      # Keep the native updater and hardening, with separate flow state per interface.
      systemd.services =
        (lib.genAttrs [ "suricata" ] (_: {
          enable = false;
        }))
        // (lib.listToAttrs (
          map (interface: lib.nameValuePair "suricata-${interface}" (instance interface)) interfaces
        ))
        // {
          suricata-update = {
            onSuccess = [ "suricata-reload-instances.service" ];
            serviceConfig = {
              Restart = "on-failure";
              RestartSec = "60s";
            };
          };
          suricata-reload-instances = {
            description = "Reload rules in active Suricata instances";
            serviceConfig.Type = "oneshot";
            script = lib.concatMapStringsSep "\n" (interface: ''
              if ${systemctl} is-active --quiet suricata-${interface}.service; then
                ${systemctl} reload suricata-${interface}.service
              fi
            '') interfaces;
          };
        };

      # A new TAP device starts capture again after the VM recreates it.
      services.udev.extraRules = lib.concatMapStringsSep "\n" (interface: ''
        SUBSYSTEM=="net", ACTION=="add", KERNEL=="${interface}", TAG+="systemd", ENV{SYSTEMD_WANTS}+="suricata-${interface}.service"
      '') interfaces;
      systemd.tmpfiles.rules = map (
        interface: "d /var/log/suricata/${interface} 0750 suricata suricata - -"
      ) interfaces;

      services.logrotate = {
        enable = true;
        settings = lib.listToAttrs (
          map (
            interface:
            lib.nameValuePair "suricata-${interface}" {
              files = [ "/var/log/suricata/${interface}/eve.json" ];
              frequency = "hourly";
              rotate = 48;
              maxsize = "256M";
              missingok = true;
              notifempty = true;
              compress = true;
              delaycompress = true;
              create = "0640 suricata suricata";
              sharedscripts = true;
              # SIGHUP closes and reopens EVE after logrotate renames the file.
              postrotate = ''
                ${systemctl} kill --kill-whom=main --signal=HUP suricata-${interface}.service 2>/dev/null || true
              '';
            }
          ) interfaces
        );
      };
      systemd.timers.suricata-update.wantedBy = [ "timers.target" ];
      systemd.timers.logrotate.timerConfig.OnCalendar = lib.mkForce "hourly";
    };
}
