{ config, lib, pkgs, ... }:
with import ../../lib/extension.nix { inherit lib; };
let
  cfg = config.programs.dma;

  relayConfig = relay: ''
    SMARTHOST ${relay.host}
    PORT ${toString relay.port}
    ${optionalString (relay.fingerprint != null) "FINGERPRINT ${relay.fingerprint}"}
    ${optionalString relay.direct "NULLCLIENT"}
  '';

  tlsConfigSettings = [ false "require-tls" "require-starttls" "allow-starttls" ];
  tlsConfigValues = [ null "SECURETRANSFER" "STARTTLS" "OPPORTUNISTIC_TLS" ];
  tlsConfig = secureTransfer:
    concatStringsSep "\n" (sublist 1 (indexOf secureTransfer tlsConfigSettings) tlsConfigValues);

  masqueradeConfig = masquerade:
    if (masquerade.user != null) && (masquerade.domain != null) then
      "MASQUERADE ${masquerade.user}@${masquerade.domain}"
    else if masquerade.user != null then
      "MASQUERADE ${masquerade.user}@"
    else if masquerade.domain != null then
      "MASQUERADE ${masquerade.domain}"
    else
      "";

  extraSettings = settings:
    concatStringsSep "\n"
      (
        mapAttrsToList
          (name: value:
            if builtins.isBool value
            then optionalString value (toUpper name)
            else "${toUpper name} ${toString value}")
          settings
      );

  configText = ''
    ${optionalString (cfg.relay != null) (relayConfig cfg.relay)}
    ${tlsConfig cfg.secureTransfer}
    ${optionalString (cfg.masquerade != null) (masqueradeConfig cfg.masquerade)}
    ${extraSettings cfg.settings}
  '';

in
{
  options = {
    programs.dma = {
      enable = mkEnableOption "DragonFly Mail Agent";

      package = mkOption {
        default = pkgs.dma;
        defaultText = "pkgs.dma";
        type = types.package;
        description = "dma package to use.";
      };

      user = mkOption {
        type = types.str;
        default = "dma";
        description = ''User to run dma as (and owner of the mail spool)'';
      };

      group = mkOption {
        type = types.str;
        default = "dma";
        description = ''Group to run dma as.'';
      };

      setSendmail = mkOption {
        type = types.bool;
        description = "Whether to set the system sendmail to dma.";
        default = true;
      };

      relay = mkOption {
        type = with types; nullOr (submodule {
          options = {
            host = mkOption {
              type = types.str;
              description = "Hostname or IP address of the relay SMTP server.";
              example = "smtp.example.com";
            };

            port = mkOption {
              type = types.port;
              description = "Port through which contact the relay SMTP server.";
              example = 25;
              default = 25;
            };

            fingerprint = mkOption {
              type = types.nullOr types.str;
              description = "SHA-256 fingerprint of the relay's TLS certificate, used for pinning.";
              default = null;
            };

            direct = mkOption {
              type = types.bool;
              description = "If enabled, mail is sent directly to the relay, bypassing aliases and local delivery.";
              default = false;
            };
          };
        });
        description = "If non-null, will relay all mail through an external SMTP server.";
        default = null;
      };

      secureTransfer = mkOption {
        type = types.enum [ false "require-tls" "require-starttls" "allow-starttls" ];
        description = "Method through which connect to the SMTP server: through an insecure connection, requiring SMTPS or STARTTLS, or allowing STARTTLS.";
        default = false;
      };

      masquerade = mkOption {
        type = with types; nullOr (submodule {
          options = {
            user = mkOption {
              type = with types; nullOr str;
              description = "Replace the local part of the envelope from address with this.";
              example = "myuser";
              default = null;
            };

            domain = mkOption {
              type = with types; nullOr str;
              description = "Replace the domain of the envelope from address with this.";
              example = "example.com";
              default = null;
            };
          };
        });
        description = ''Change the "envelope from" address of outgoing emails.'';
        default = null;
      };

      settings = mkOption {
        type = with types; attrsOf (oneOf [ bool int str ]);
        description = ''Additional configuration.'';
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."dma/dma.conf" = { text = configText; };

    users = {
      users.${cfg.user} = {
        description = "DragonFly Mail Agent";
        group = cfg.group;
        home = "/var/spool/dma";
        createHome = true;
      };
      groups.${cfg.group} = { };
    };

    environment.systemPackages = [ cfg.package ];
    services.mail.sendmailSetuidWrapper = mkIf cfg.setSendmail {
      program = "sendmail";
      source = "${cfg.package}/bin/dma";
      owner = cfg.user;
      group = cfg.group;
      setuid = true;
      setgid = true;
    };
  };
}
