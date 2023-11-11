{ config, lib, ... }:
let
  cfg = config.my.home.documentation;
in
{
  options.my.home.documentation = with lib; {
    enable = my.mkDisableOption "documentation integration";
  };

  # Add documentation for user packages
  config.programs.man = {
    enable = cfg.enable;
    generateCaches = true; # Enables the use of `apropos` etc...
  };

  config.programs.info.enable = cfg.enable;
}
