{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.dropbear;
in
{
  options = {
    sane.services.dropbear = with lib; {
      enable = mkEnableOption "dropbear SSH server";
      package = mkPackageOption pkgs "dropbear" {};

      port = mkOption {
        type = types.port;
        default = 22;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.dropbear = {
      description = "Dropbear SSH Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
      # N.B.: dropbear ssh key format is incompatible with OpenSSH's.
      # also, needs to be manually generated on first run (`dropbearkey -t rsa -f /etc/ssh/host_keys/dropbear_rsa_host_key -s 4096`)
      serviceConfig.ExecStart = "${lib.getExe' cfg.package "dropbear"} -F -p ${builtins.toString cfg.port} -r /etc/ssh/host_keys/dropbear_rsa_host_key -r /etc/ssh/host_keys/dropbear_ed25519_host_key";
    };
  };
}
