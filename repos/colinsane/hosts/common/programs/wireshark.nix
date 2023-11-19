{ config, ... }:
{
  sane.programs.wireshark.slowToBuild = true;

  programs.wireshark.enable = config.sane.programs.wireshark.enabled;
}
