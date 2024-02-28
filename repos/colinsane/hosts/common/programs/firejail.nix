{ lib, config, ... }:
{
  sane.programs.firejail = {};

  programs.firejail = lib.mkIf config.sane.programs.firejail.enabled {
    enable = true;  #< install the suid binary
  };
}
