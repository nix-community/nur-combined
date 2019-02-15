{ config, lib, pkgs, ... }:

with lib;
let
  # not ideal, as now the package can't be easily overridden
  # TODO: find a way to specify it that works with NUR and just my own
  # nur-packages repo
  lenovo-throttling-fix = pkgs.callPackage ../../pkgs/throttled {};
in {
  meta.maintainers = [ maintainers.moredread ];

  options = {
    services.lenovo-throttling-fix = {
      enable = mkEnableOption "the Lenovo throttling fix";
    };
  };

  config = mkIf config.services.lenovo-throttling-fix.enable {
    systemd.services.lenovo-throttling-fix = {
      description = "Lenovo throttling fix";

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lenovo-throttling-fix}/bin/lenovo_fix --config ${lenovo-throttling-fix}/etc/lenovo_fix.conf";
      };
    };
  };
}
