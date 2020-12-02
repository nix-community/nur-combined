{ config, lib, pkgs, ... }:

with lib;
let
  stateDir = "/run/dyndnsc";

  runtimeConfigFile = "${stateDir}/config.ini";

  cfg = config.services.dyndnsc;

  profileConfigs =
    mapAttrsToList
      (name: profile: ''
        [${name}]
        ${optionalString (profile.preset != "") "use_preset = ${profile.preset}"}
        updater-hostname = ${profile.hostname}
        updater-userid = ${profile.username}
        updater-password = %(password_${name})s
        ${profile.extraConfig}
      '')
      cfg.profiles;

  configFile = pkgs.writeText "dyndnsc.ini" ''
    [dyndnsc]
    configs = ${concatStringsSep ", " (attrNames cfg.profiles)}

    ${concatStrings profileConfigs}
  '';

in
{
  options = {
    services.dyndnsc = {
      enable = mkEnableOption "dyndnsc Dynamic DNS client";

      package = mkOption {
        default = pkgs.dyndnsc;
        defaultText = "pkgs.dyndnsc";
        type = types.package;
        description = "dyndnsc package to use.";
      };

      profiles = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            preset = mkOption {
              type = types.nullOr (types.enum [
                # Keep in sync with dyndnsc/resources/presets.ini in the source.
                "no-ip.com"
                "freedns.afraid.com"
                "nsupdate.info:ipv4"
                "nsupdate.info:ipv6"
                "dns.he.net"
                "dnsimple.com"
                "dnsdynamic.org"
                "hopper.pw:ipv4"
                "hopper.pw:ipv6"
                "dyn.com"
                "duckdns.org"
              ]);
              default = null;
              description = ''
                Preset profile to inherit.
              '';
              example = "dns.he.net";
            };
            hostname = mkOption {
              type = types.str;
              description = "Hostname or domain to be updated.";
              example = "dynamic.example.com";
            };
            username = mkOption {
              type = types.str;
              description = "Username to login with in the dynamic DNS service.";
            };
            passwordFile = mkOption {
              type = types.path;
              description = "Path to a file containing the service's password.";
              example = "/run/keys/dyndnsc-myprofile";
            };
            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = "Additional profile parameters.";
            };
          };
        });
        example = literalExample ''
          {
            "myhost_ip4" = {
              preset = "nsupdate.info:ipv4";
              hostname = "dynamic.example.com";
              username = "me";
              passwordFile = "/run/keys/dyndnsc-myhost_ip4";
            };
          };
        '';
        description = "Declarative profile config";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dyndnsc = {
      description = "Dynamic DNS client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      stopIfChanged = true;
      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/dyndnsc --verbose --loop --config "${runtimeConfigFile}"'';
        Restart = "on-failure";
        RestartIntervalSec = 30;
      };
      preStart =
        let
          profilePasswords = concatStrings (
            mapAttrsToList
              (name: profile: ''
                password_${name} = $(cat "${profile.passwordFile}")
              '')
              cfg.profiles
          );
        in
        ''
          mkdir -p "${stateDir}"
          install -m0600 /dev/null "${runtimeConfigFile}"
          cat "${configFile}" - >"${runtimeConfigFile}" <<EOF
          [DEFAULT]
          ${profilePasswords}
          EOF
        '';
      postStop = ''
        rm -f "${runtimeConfigFile}"
      '';
    };
  };
}
