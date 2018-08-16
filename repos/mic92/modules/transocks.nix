{ config, lib, pkgs, ... }:

let
  cfg = config.services.transocks;

  configFile = let
    json = builtins.toJSON ({ proxy_url = cfg.proxyUrl; } // cfg.extraConfig);
  in pkgs.runCommand "transocks.toml" {
    buildInputs = [ pkgs.remarshal ];
  } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "config.json" json} \
      > $out
  '';
in {
  ###### interface
  options = {
    services.transocks = {
      enable = mkEnableOption "transocks server";

      proxyUrl = mkOption {
        default = "socks5://localhost:1080";
        description = "SOCKS5 or HTTP proxy to redirect to";
        type = types.string;
        example = "http://10.20.30.40:1080";
      };

      extraConfig = mkOption {
        default = {};
        description = "Extra configuration options for telegraf";
        type = types.attrs;
        example = {
          listen = "localhost:1081";
        };
      };
    };
  };


  ###### implementation
  config = mkIf config.services.transocks.enable {
    systemd.services.transocks = {
      description = "Transocks";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.nur.repo.mic92.transocks}/bin/transocks -f ${configFile}";
        DynamicUser = true;
        Restart = "on-failure";
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
      };
    };
  };

  meta.maintainers = [ maintainers.mic92 ];
}
