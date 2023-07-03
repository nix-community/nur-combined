{ config, ... }:
{
  programs.wireshark.enable = config.sane.programs.wireshark.enabled;
}
