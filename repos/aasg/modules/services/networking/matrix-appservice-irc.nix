{ config, lib, pkgs, ... }:
with import ../../../lib/extension.nix { inherit lib; };
let
  format = pkgs.formats.yaml { };
  cfg = config.services.matrix-appservice-irc;
  pkg = cfg.package;

  configSchema = pkgs.runCommand "matrix-appservice-irc-schema.json"
    {
      nativeBuildInputs = with pkgs; [ remarshal ];
    }
    ''
      remarshal -if yaml -of json <${pkg}/lib/node_modules/matrix-appservice-irc/config.schema.yml >$out
    '';
  configFile = pkgs.runCommandLocal "matrix-appservice-irc.json"
    {
      nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.jsonschema ])) ];
      config = builtins.toJSON cfg.settings;
      passAsFile = [ "config" ];
    }
    ''
      python -m jsonschema ${configSchema} -i $configPath
      cp $configPath $out
    '';
  registrationFile =
    let
      hs = cfg.settings.homeserver;
      hostname =
        if (builtins.match "^[[:xdigit:]:]{2,39}$" hs.bindHostname) != null
        then "[${hs.bindHostname}]" # IPv6 literal
        else hs.bindHostname;
      serviceUrl = "http://${hostname}:${toString hs.bindPort}";
    in
    pkgs.runCommandLocal "matrix-appservice-registration-irc.json"
      {
        nativeBuildInputs = with pkgs; [ jq remarshal ];
      }
      ''
        ${pkg}/bin/matrix-appservice-irc --config ${configFile} --file registration.yaml --generate-registration --url "${serviceUrl}"
        remarshal -if yaml -of json <registration.yaml >registration.json
        jq 'del(.id, .as_token, .hs_token)' <registration.json >$out
      '';

  reconfigureScript = pkgs.writeScript "matrix-appservice-reconfigure" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail
    PATH=${makeBinPath [ pkgs.jq pkgs.openssl ]}
    cd /etc/matrix-appservice-irc

    function mergeJSON {
      jq --slurp 'reduce .[] as $item ({}; . * $item)' "$@"
    }

    # Replace bot passwords in config file.
    umask 077
    {
    ${concatStringsSep "\n" (flip mapAttrsToList cfg.botPasswordFiles (server: passwordFile: ''
      jq --null-input \
        --arg server "${server}" --rawfile password "${passwordFile}" \
        '{ircService: {servers: {($server): {botConfig: {password: $password | rtrimstr("\n")}}}}}'
    ''))}
    } | mergeJSON ${configFile} - >config.json

    # Create the registration secrets, if necessary.
    umask 077
    if [[ ! -f registration-secrets.json ]]; then
      openssl rand -hex 64 \
      | jq --arg id "matrix-appservice-irc" --raw-input '{$id, as_token: .[:64], hs_token: .[64:]}' \
      >registration-secrets.json
    fi

    # Merge the registration secrets and the registration file.
    umask 027
    mergeJSON ${registrationFile} registration-secrets.json >registration.yaml
  '';
in
{
  options = {
    services.matrix-appservice-irc = {
      enable = mkEnableOption "Matrix bridge to IRC";

      package = mkOption {
        type = types.package;
        default = pkgs.matrix-appservice-irc;
        defaultText = "pkgs.matrix-appservice-irc";
        description = "matrix-appservice-irc package to use.";
      };

      settings = mkOption {
        type = format.type;
        default = { };
        description = "Additional service settings.";
      };

      botPasswordFiles = mkOption {
        type = types.attrsOf types.path;
        description = ''
          Attrset mapping IRC servers to files containing the password
          of the bridge bot on that server.
        '';
        default = { };
        example = ''
          { "chat.freenode.net" = "/etc/matrix-appservice-irc/freenode.password"; }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [
        {
          assertion = isSubsetOf (builtins.attrNames cfg.settings.ircService.servers) (builtins.attrNames cfg.botPasswordFiles);
          message = "botPasswordFiles references servers not present in the settings";
        }
      ];

    systemd.services.matrix-appservice-irc = {
      description = "Matrix bridge to IRC";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = rec {
        Type = "simple";
        ExecStartPre = reconfigureScript;
        ExecStart = "${pkg}/bin/matrix-appservice-irc --config /etc/matrix-appservice-irc/config.json --file /etc/matrix-appservice-irc/registration.yaml";
        ExecReload = [ reconfigureScript "${pkgs.coreutils}/bin/kill -HUP $MAINPID" ];
        DynamicUser = true;
        ProtectHome = true;
        PrivateDevices = true;
        ConfigurationDirectory = "matrix-appservice-irc";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        CapabilityBoundingSet = [ ];
        AmbientCapabilities = CapabilityBoundingSet;
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;
        PrivateMounts = true;
        SystemCallFilter = "~@aio @clock @cpu-emulation @debug @keyring @memlock @module @mount @obsolete @raw-io @setuid @swap";
        SystemCallArchitectures = "native";
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
      };
    };
  };
}
