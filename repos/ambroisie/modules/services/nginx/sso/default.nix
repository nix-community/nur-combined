# I must override the module to allow having runtime secrets
{ config, lib, pkgs, utils, ... }:
let
  cfg = config.services.nginx.sso;
  pkg = lib.getBin cfg.package;
  confPath = "/var/lib/nginx-sso/config.json";
in
{
  disabledModules = [ "services/security/nginx-sso.nix" ];


  options.services.nginx.sso = with lib; {
    enable = mkEnableOption "nginx-sso service";

    package = mkOption {
      type = types.package;
      default = pkgs.nginx-sso;
      defaultText = "pkgs.nginx-sso";
      description = ''
        The nginx-sso package that should be used.
      '';
    };

    configuration = mkOption {
      type = types.attrsOf types.unspecified;
      default = { };
      example = literalExample ''
        {
          listen = { addr = "127.0.0.1"; port = 8080; };

          providers.token.tokens = {
            myuser = "MyToken";
          };

          acl = {
            rule_sets = [
              {
                rules = [ { field = "x-application"; equals = "MyApp"; } ];
                allow = [ "myuser" ];
              }
            ];
          };
        }
      '';
      description = ''
        nginx-sso configuration
        (<link xlink:href="https://github.com/Luzifer/nginx-sso/wiki/Main-Configuration">documentation</link>)
        as a Nix attribute set.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nginx-sso = {
      description = "Nginx SSO Backend";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        StateDirectory = "nginx-sso";
        WorkingDirectory = "/var/lib/nginx-sso";
        # The files to be merged might not have the correct permissions
        ExecStartPre = ''+${pkgs.writeScript "merge-nginx-sso-config" ''
          #!${pkgs.bash}/bin/bash
          rm -f '${confPath}'
          ${utils.genJqSecretsReplacementSnippet cfg.configuration confPath}

          # Fix permissions
          chown nginx-sso:nginx-sso ${confPath}
          chmod 0600 ${confPath}
        ''
        }'';
        ExecStart = lib.mkForce ''
          ${pkg}/bin/nginx-sso \
            --config ${confPath} \
            --frontend-dir ${pkg}/share/frontend
        '';
        Restart = "always";
        User = "nginx-sso";
        Group = "nginx-sso";
      };
    };

    users.users.nginx-sso = {
      isSystemUser = true;
      group = "nginx-sso";
    };

    users.groups.nginx-sso = { };
  };
}
