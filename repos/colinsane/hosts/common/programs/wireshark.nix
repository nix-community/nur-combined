{ config, ... }:
{
  sane.programs.wireshark = {};
  programs.wireshark.enable = config.sane.programs.wireshark.enabled;
}
