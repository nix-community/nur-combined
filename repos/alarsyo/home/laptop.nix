{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    ;
in {
  options.my.home.laptop = {
    enable = mkEnableOption "Laptop settings";
  };
}
