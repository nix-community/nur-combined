{ lib, ... }:
{
  options.nixcfg.gui.enable = lib.mkEnableOption "GUI Applications";
}
