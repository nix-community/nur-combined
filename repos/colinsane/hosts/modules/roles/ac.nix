{ config, lib, ... }:
{
  options.sane.roles.ac = with lib; mkOption {
    type = types.bool;
    default = false;
    description = ''
      services which you probably only want to use with AC power.
      specifically because they drain resources like power or bandwidth.
    '';
  };

  config = lib.mkIf config.sane.roles.ac {
    sane.yggdrasil.enable = true;
    services.i2p.enable = true;
  };
}
