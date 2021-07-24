{ config, lib, ... }:
{
  options.my.home.laptop = with lib; {
    enable = mkEnableOption "Laptop settings";
  };
}
