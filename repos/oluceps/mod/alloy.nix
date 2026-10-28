{
  flake.modules.nixos.alloy-realm =
    { config, lib, ... }:
    {
      services.alloy.enable = lib.mkIf (config.realm.internet.enable or false) (lib.mkDefault true);
      realm.workloads.alloy = lib.mkIf config.services.alloy.enable {
        isolation.allowUnixSockets = [
          "-/run/log/journal"
          "-/run/systemd/journal"
        ];
        egress.loki = {
          service = "loki";
          localPort = 13030;
        };
      };
      environment.etc = lib.mkMerge [
        (lib.mkIf (config.realm.spire.metrics.enable or false) {
          "alloy/realm-identity.alloy".text =
            let
              units = [
                "spire-agent.service"
                "spire-server.service"
                "realm-node-attest-responder.service"
                "realm-spire-register.service"
                "realm-identity-metrics.service"
                "realm-observability.service"
              ]
              ++ map (unit: "${unit}.service") (builtins.attrNames config.realm.spire.metrics.statusPorts);
            in
            ''
              discovery.relabel "identity_journal" {
                targets = []
                rule {
                  source_labels = ["__journal__systemd_unit"]
                  target_label = "unit"
                }
              }
              loki.source.journal "identity" {
                max_age = "12h0m0s"
                matches = "${lib.concatMapStringsSep " " (unit: "_SYSTEMD_UNIT=${unit}") units}"
                relabel_rules = discovery.relabel.identity_journal.rules
                forward_to = [loki.write.realm_identity.receiver]
                labels = {
                  host = "${config.networking.hostName}",
                  job = "systemd-journal",
                  subsystem = "identity",
                }
              }
              loki.write "realm_identity" {
                endpoint {
                  url = "http://127.0.0.1:13030/loki/api/v1/push"
                }
                external_labels = {}
              }
            '';
        })
        (lib.mkIf (config.realm.internet.enable or false) {
          "alloy/realm-internet.alloy".text = # alloy
            ''
              loki.source.journal "realm_internet" {
                  max_age       = "12h0m0s"
                  forward_to    = [loki.write.realm_internet.receiver]
                  matches       = "_SYSTEMD_UNIT=realm-internet.service"
                  labels        = {
                      host = "${config.networking.hostName}",
                      job  = "systemd-journal",
                      unit = "realm-internet.service",
                  }
              }
              loki.write "realm_internet" {
                endpoint {
                  url = "http://127.0.0.1:13030/loki/api/v1/push"
                }
                external_labels = {}
              }
            '';
        })
      ];
      systemd.services.alloy.restartTriggers = lib.mkIf (config.realm.spire.metrics.enable or false) [
        config.environment.etc."alloy/realm-identity.alloy".source
      ];
    };
  flake.modules.nixos.alloy =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      publicMeshNodes = import ../lib/public-mesh-nodes.nix {
        inherit lib;
        nodes = config.data.node;
        hostName = config.networking.hostName;
      };
      # Suricata writes IPv6 addresses with eight padded groups.
      suricataAddress =
        addr:
        if !(lib.hasInfix ":" addr) then
          addr
        else
          let
            halves = lib.splitString "::" addr;
            groups = part: lib.filter (group: group != "") (lib.splitString ":" part);
            left = groups (builtins.head halves);
            right = if builtins.length halves == 2 then groups (builtins.elemAt halves 1) else [ ];
            expanded =
              if builtins.length halves == 2 then
                left ++ lib.replicate (8 - builtins.length left - builtins.length right) "0" ++ right
              else
                left;
          in
          lib.concatMapStringsSep ":" (group: lib.fixedWidthString 4 "0" (lib.toLower group)) expanded;
      meshPeerTemplate =
        lib.concatStrings (
          lib.imap0 (
            index: name:
            let
              matches =
                lib.concatMapStringsSep " "
                  (addr: "(eq .src ${builtins.toJSON addr}) (eq .dst ${builtins.toJSON addr})")
                  (
                    lib.unique (
                      lib.concatMap (addr: [
                        addr
                        (suricataAddress addr)
                      ]) publicMeshNodes.${name}
                    )
                  );
            in
            "{{ ${if index == 0 then "if" else "else if"} or ${matches} }}${name}"
          ) (builtins.attrNames publicMeshNodes)
        )
        + "{{ else }}unknown{{ end }}";
    in
    {
      services.alloy = {
        enable = true;
      };
      # Reload keeps the old /etc files in the service mount namespace.
      systemd.services.alloy.restartTriggers = config.systemd.services.alloy.reloadTriggers;
      systemd.services.alloy.serviceConfig = {
        ReadOnlyPaths = [ "-/var/log/suricata" ];
        SupplementaryGroups = [ "suricata" ];
      };
      environment.etc."alloy/config.alloy".text = # alloy
        ''
          livedebugging {
            enabled = false
          }
          discovery.relabel "journal" {
          	targets = []
          	rule {
          		source_labels = ["__journal__systemd_unit"]
          		target_label  = "unit"
          	}
          }
          loki.source.journal "sshd" {
              max_age       = "12h0m0s"
              relabel_rules = discovery.relabel.journal.rules
              forward_to    = [loki.write.default.receiver]
              matches       = "_SYSTEMD_UNIT=sshd.service"
              labels        = {
                  host = "${config.networking.hostName}",
                  job  = "systemd-journal",
              }
          }
          loki.source.journal "sudo" {
              max_age       = "12h0m0s"
              relabel_rules = discovery.relabel.journal.rules
              forward_to    = [loki.write.default.receiver]
              matches       = "_COMM=sudo"
              labels        = {
                  host = "${config.networking.hostName}",
                  job  = "systemd-journal",
                  comm = "sudo",
              }
          }
          loki.source.journal "kernel" {
              max_age       = "12h0m0s"
              relabel_rules = discovery.relabel.journal.rules
              forward_to    = [loki.write.default.receiver]
              matches       = "_TRANSPORT=kernel"
              labels        = {
                  host = "${config.networking.hostName}",
                  job  = "systemd-journal",
              }
          }
          local.file_match "suricata" {
            path_targets = [
              {
                "__path__" = "/var/log/suricata/vm1/eve.json",
                "host" = "${config.networking.hostName}",
                "job" = "suricata",
                "interface" = "vm1",
              },
              {
                "__path__" = "/var/log/suricata/eno1/eve.json",
                "host" = "${config.networking.hostName}",
                "job" = "suricata",
                "interface" = "eno1",
              },
              {
                "__path__" = "/var/log/suricata/vxlan-mesh/eve.json",
                "host" = "${config.networking.hostName}",
                "job" = "suricata",
                "interface" = "vxlan-mesh",
              },
            ]
            sync_period = "5s"
          }

          loki.source.file "suricata" {
            targets    = local.file_match.suricata.targets
            forward_to = [loki.process.suricata.receiver]
          }

          loki.process "suricata" {
            stage.json {
              expressions = {
                ts         = "timestamp",
                event_type = "event_type",
                src        = "src_ip",
                spt        = "src_port",
                dst        = "dest_ip",
                dpt        = "dest_port",
                proto      = "proto",
              }
            }

            stage.timestamp {
              source = "ts"
              format = "RFC3339Nano"
              fallback_formats = ["2006-01-02T15:04:05.999999-0700"]
              action_on_failure = "skip"
            }

            stage.labels {
              values = {
                event_type = "",
                proto = "",
              }
            }

            stage.match {
              selector = "{interface=\"vxlan-mesh\"}"
              stage.template {
                source = "peer_node"
                template = ${builtins.toJSON meshPeerTemplate}
              }
              stage.labels {
                values = { peer_node = "" }
              }
            }

            stage.match {
              selector = "{event_type=\"flow\"}"

              stage.geoip {
                source  = "dst"
                db      = "${
                  let
                    sources = import ../_sources/generated.nix {
                      inherit (pkgs)
                        fetchurl
                        fetchgit
                        fetchFromGitHub
                        dockerTools
                        ;
                    };
                  in
                  sources.GeoLite2-ASN.src
                }"
                db_type = "asn"
              }
              stage.geoip {
                source  = "dst"
                db      = "${
                  let
                    sources = import ../_sources/generated.nix {
                      inherit (pkgs)
                        fetchurl
                        fetchgit
                        fetchFromGitHub
                        dockerTools
                        ;
                    };
                  in
                  sources.GeoLite2-City.src
                }"
                db_type = "city"
              }
            }
            stage.structured_metadata {
                values = {
                  src      = "",
                  spt      = "",
                  dst      = "",
                  dpt      = "",
                  dst_city = "geoip_city_name",
                  dst_asn  = "geoip_autonomous_system_organization",
                  dst_lat  = "geoip_location_latitude",
                  dst_lon  = "geoip_location_longitude",
                }
            }
            forward_to = [loki.write.default.receiver]
          }

          loki.write "default" {
          	endpoint {
              url = "http://127.0.0.1:13030/loki/api/v1/push"
          	}
          	external_labels = {}
          }
        '';
    };
}
