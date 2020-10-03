{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nginx.sso;
  pkg = getBin cfg.package;
  configYml =
    pkgs.writeText "nginx-sso.yml" (builtins.toJSON cfg.configuration);
in {
  # Override existing module.
  disabledModules = [ "services/security/nginx-sso.nix" ];  

  options.services.nginx.sso = {
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

    secrets = mkOption {
      type = types.attrsOf types.path;
      default = { };
      example = literalExample ''
        {
          ".cookie.authentication_key" = "/secrets/nginx-sso/authentication_key";
        }
      '';
      description = ''
        Inserts values in the configuration yaml with the contents read from the secret file.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nginx-sso = {
      description = "Nginx SSO Backend";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        RuntimeDirectory = "nginx-sso";
        RuntimeDirectoryMode = 750;
        ExecStartPre = let
          preStart = ''
            mkdir -p $RUNTIME_DIRECTORY -m 750
            chown nginx-sso:nginx-sso $RUNTIME_DIRECTORY

            export config=$RUNTIME_DIRECTORY/config.yml
            cp ${configYml} $config
            chmod 640 $config
            chown nginx-sso:nginx-sso $config

            ${concatStringsSep "\n" (attrValues (flip mapAttrs cfg.secrets
              (key: path: ''
                export secret="$(<'${path}')"
                ${pkgs.yq}/bin/yq -y '${key}=$ENV.secret' $config \
                  | ${pkgs.moreutils}/bin/sponge $config
              '')))}
          '';
        in "!${pkgs.writeShellScript "nginx-sso-pre-start" preStart}";

        ExecStart = pkgs.writeShellScript "nginx-sso" ''
          ${pkg}/bin/nginx-sso \
            --config $RUNTIME_DIRECTORY/config.yml \
            --frontend-dir ${pkg}/share/frontend
        '';
        
        Restart = "always";
        DynamicUser = true;
      };
    };
  };
}
