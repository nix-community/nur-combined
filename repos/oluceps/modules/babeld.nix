{
  config,
  lib,
  pkgs,
  ...
}:
let

  inherit (pkgs) writeText;
  cfg = config.services.babeld;
  configFile = writeText "babeld.conf" cfg.config;

in

{
  disabledModules = [ "services/networking/babeld.nix" ];

  options = {

    services.babeld = {

      enable = lib.mkEnableOption "the babeld network routing daemon";

      config = lib.mkOption {
        default = "";
        type = lib.types.lines;
        description = ''
          Options that will be copied to babeld.conf.
          See {manpage}`babeld(8)` for details.
        '';
      };
    };

  };

  config = lib.mkIf cfg.enable {

    networking.firewall.allowedUDPPorts = [ 6696 ];

    systemd.services.babeld = {
      description = "Babel routing daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.babeld}/bin/babeld -c ${configFile} -I /run/babeld/babeld.pid -S /var/lib/babeld/state";
        ProcSubset = "pid";
        RuntimeDirectory = "babeld";
        StateDirectory = "babeld";
      };
    };
  };
}
