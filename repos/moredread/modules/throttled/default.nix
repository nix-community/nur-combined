{ config, lib, pkgs, ... }:

with lib;
let
  # not ideal, as now the package can't be easily overridden
  # TODO: find a way to specify it that works with NUR and just my own
  # nur-packages repo
  throttled = pkgs.callPackage ../../pkgs/throttled {};
in
{
  meta.maintainers = [ maintainers.moredread ];

  options = {
    services.throttled-custom = {
      enable = mkEnableOption "the Lenovo throttling fix";
    };
  };

  config = mkIf config.services.throttled-custom.enable {
    systemd.services.throttled = {
      description = "Lenovo throttling fix";

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${throttled}/bin/lenovo_fix --config ${throttled}/etc/lenovo_fix.conf";
      };
    };
  };
}
