{ config, lib, ... }:

let
  cfg = config.sane.persist;
in
{
  fileSystems."/" = lib.mkIf (cfg.enable && cfg.root-on-tmpfs) {
    device = "none";
    fsType = "tmpfs";
    options = [
      "mode=755"
      "size=1G"
      "defaults"
    ];
  };
}
