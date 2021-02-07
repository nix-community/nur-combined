{pkgs, lib, config, ...}:
with builtins;
with lib;
let
  cfg = config.services.vercel-ddns;
in
{
  options = {
    services.vercel-ddns = {
      enable = mkEnableOption "Enable vercel-ddns service";
      vercelTokenFile = mkOption {
        type = types.path;
        description = "The autorization token for authentication";
      };
      domain = mkOption {
        type = types.str;
        description = "The base domain to attach this machine to";
      };
      names = mkOption {
        type = types.listOf types.str;
        description = "The names of this machine subdomains";
      };
      fetch-ip = mkOption {
        type = types.str;
        description = "Bash expression to get the current ip";
        default = "curl ifconfig.me";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd = {
      services.vercel-ddns = {
        description = "vercel-ddns agent";
        after = [ "network-online.target" ];
        enable = true;
        wants = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = 10;
        };
        script = "${pkgs.writeShellScript "vercel-ddns" ''
          PATH=$PATH:${pkgs.curl}/bin
          IP=$(${cfg.fetch-ip})
          ${concatStringsSep "\n" (
          map (name: ''
            curl -X POST "https://api.vercel.com/v2/domains/${cfg.domain}/records" \
              -H "Authorization: Bearer $(cat ${toString cfg.vercelTokenFile})" \
              -H "Content-Type: application/json" \
              -d "{
                \"name\": \"${name}\",
                \"type\": \"A\",
                \"value\": \"$IP\",
                \"ttl\": 60
              }"
          '') cfg.names)}
          ''
        }";
      };
    };
  };
}
