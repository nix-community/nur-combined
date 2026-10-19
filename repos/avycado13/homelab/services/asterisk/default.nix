{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "asterisk";
  hl = config.homelab;
  cfg = hl.services.${service};

  ciscoProvDir = "/var/lib/asterisk/cisco-provisioning";

  atftpPkg = pkgs.atftp;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption "Enable ${service}";
    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Tailscale IP/hostname where asterisk actually runs, if not this machine";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "pbx.${hl.baseDomainName}";
      description = "Domain for SIP registration and Caddy admin UI";
    };
    glance.name = lib.mkOption {
      type = lib.types.str;
      default = "Asterisk PBX";
    };
    glance.url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "No web UI bookmark by default (SIP service)";
    };
    rtpPortRange = {
      start = lib.mkOption {
        type = lib.types.port;
        default = 10000;
        description = "Start of RTP media port range";
      };
      end = lib.mkOption {
        type = lib.types.port;
        default = 20000;
        description = "End of RTP media port range";
      };
    };
    phones = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            mac = lib.mkOption {
              type = lib.types.str;
              description = "MAC address of the Cisco phone (no separators, e.g. 001122334455)";
            };
            line1Secret = lib.mkOption {
              type = lib.types.str;
              description = "SIP password for line 1, e.g. config.sops.placeholder.asterisk-cisco7945-password";
            };
            line1DisplayName = lib.mkOption {
              type = lib.types.str;
              default = "Line 1";
            };
            line2Secret = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "SIP password for line 2, e.g. config.sops.placeholder.<name>";
            };
            line2DisplayName = lib.mkOption {
              type = lib.types.str;
              default = "Line 2";
            };
            callerId = lib.mkOption {
              type = lib.types.str;
              description = "Caller ID string for this phone (e.g. 'Avy')";
            };
            extension = lib.mkOption {
              type = lib.types.str;
              description = "Dial extension for this phone (e.g. '1001')";
            };
          };
        }
      );
      default = [ ];
      description = "Cisco IP phones to provision via TFTP";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = cfg.url;
      description = "SIP domain (defaults to url)";
    };
    extraConfFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra Asterisk conf files to override/append (passed to services.asterisk.confFiles)";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      phoneConfigs = map (
        phone:
        let
          macUpper = lib.toUpper phone.mac;
        in
        {
          name = "SEP${macUpper}";
          inherit (phone) extension callerId line1Secret;
          cnfXml = pkgs.writeText "SEP${macUpper}.cnf.xml" ''
            <device>
              <deviceProtocol>SIP</deviceProtocol>
              <devicePool>
                <dateTimeSetting>
                  <name>CML</name>
                  <dateTemplate>D/M/YA</dateTemplate>
                  <timeZone>UTC</timeZone>
                  <ntps>
                    <ntp>
                      <name>pool.ntp.org</name>
                      <ntpMode>Unicast</ntpMode>
                    </ntp>
                  </ntps>
                </dateTimeSetting>
                <callManagerGroup>
                  <members>
                    <member priority="0">
                      <callManager>
                        <name>${cfg.domain}</name>
                        <ports>
                          <sipPort>5060</sipPort>
                          <securedSipPort>5061</securedSipPort>
                        </ports>
                      </callManager>
                    </member>
                  </members>
                </callManagerGroup>
              </devicePool>
              <sipProfile>
                <sipProxies>
                  <backupProxy>${cfg.domain}</backupProxy>
                  <backupProxyPort>5060</backupProxyPort>
                  <outboundProxy>${cfg.domain}</outboundProxy>
                  <outboundProxyPort>5060</outboundProxyPort>
                  <registerWithProxy>true</registerWithProxy>
                </sipProxies>
                <sipCallFeatures>
                  <localRingtone>true</localRingtone>
                </sipCallFeatures>
                <transportProtocol>sip</transportProtocol>
              </sipProfile>
              <vendorConfig>
                <g722CodecSupport>1</g722CodecSupport>
                <handsetWidebandEnable>1</handsetWidebandEnable>
                <headsetWidebandEnable>1</headsetWidebandEnable>
                <speakerWidebandEnable>1</speakerWidebandEnable>
              </vendorConfig>
            </device>
          '';
        }
      ) cfg.phones;

      pjsipConfTemplate = ''
        [transport-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0:5060

        [transport-tcp]
        type=transport
        protocol=tcp
        bind=0.0.0.0:5060

      ''
      + lib.concatStringsSep "\n" (
        map (phone: ''
          [${phone.name}]
          type=endpoint
          context=from-internal
          disallow=all
          allow=g722
          allow=ulaw
          allow=alaw
          direct_media=no
          rtp_symmetric_comedia=yes
          force_rport=yes
          rewrite_contact=yes
          device_state_busy_at_inuse=yes
          auth=${phone.name}
          aors=${phone.name}
          callerid="${phone.callerId}" <${phone.extension}>

          [${phone.name}]
          type=auth
          auth_type=userpass
          username=${phone.name}
          password=${phone.line1Secret}

          [${phone.name}]
          type=aor
          max_contacts=1
          remove_existing=yes
        '') phoneConfigs
      );

      extensionsConf = ''
        [general]

        [globals]

        [from-internal]
        ${lib.concatStringsSep "\n" (
          map (phone: ''
            exten => ${phone.extension},1,Dial(PJSIP/${phone.name},30)
            same => n,Voicemail(${phone.name},u)
            same => n,Hangup()
          '') phoneConfigs
        )}
      '';

      rtpConf = ''
        [general]
        rtpstart=${toString cfg.rtpPortRange.start}
        rtpend=${toString cfg.rtpPortRange.end}
      '';

      voicemailConf = ''
        [general]
        format=wav49|gsm|wav

        ${lib.concatStringsSep "\n" (
          map (phone: ''
            [${phone.name}]
            context=from-internal
          '') phoneConfigs
        )}
      '';

    in
    lib.mkMerge [
      (lib.mkIf (cfg.host == "127.0.0.1") {
        services.asterisk = {
          enable = true;
          confFiles = {
            "extensions.conf" = extensionsConf;
            "rtp.conf" = rtpConf;
            "voicemail.conf" = voicemailConf;
          }
          // cfg.extraConfFiles;
        };

        sops.templates."asterisk/pjsip.conf" = {
          owner = "asterisk";
          group = "asterisk";
          mode = "0440";
          content = pjsipConfTemplate;
        };

        environment.etc."asterisk/pjsip.conf".source =
          lib.mkForce
            config.sops.templates."asterisk/pjsip.conf".path;

        networking.firewall = {
          allowedUDPPorts = [
            5060
            69
          ];
          allowedTCPPorts = [ 5060 ];
          allowedUDPPortRanges = [
            {
              from = cfg.rtpPortRange.start;
              to = cfg.rtpPortRange.end;
            }
          ];
        };

        systemd.services.atftpd = {
          description = "Advanced TFTP server for Cisco phone provisioning";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            ExecStart = "${atftpPkg}/bin/atftpd --port 69 --user asterisk.asterisk ${ciscoProvDir}";
            Restart = "on-failure";
            RestartSec = "5";
          };
        };

        systemd.services.asterisk-cisco-provisioning = {
          description = "Generate Cisco IP phone provisioning files for Asterisk";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          before = [ "atftpd.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            mkdir -p ${ciscoProvDir}
            chown asterisk:asterisk ${ciscoProvDir}
          ''
          + lib.concatStringsSep "\n" (
            map (phone: ''
              cp ${phone.cnfXml} ${ciscoProvDir}/${phone.name}.cnf.xml
              chown asterisk:asterisk ${ciscoProvDir}/${phone.name}.cnf.xml
            '') phoneConfigs
          );
        };

        systemd.services.asterisk = {
          requires = [ "sops-nix.service" ];
          after = [ "sops-nix.service" ];
          serviceConfig = lib.mkIf (hl.notifications.ntfySecretsFile != null) {
            OnFailure = "notify-failure@%n.service";
          };
        };
      })
      {
        services.caddy.virtualHosts."${cfg.url}" = {
          useACMEHost = hl.baseDomainName;
          extraConfig = ''
            reverse_proxy http://${cfg.host}:8088
          '';
        };
      }
    ]
  );
}
