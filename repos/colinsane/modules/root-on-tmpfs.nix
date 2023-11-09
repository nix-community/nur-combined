{ config, lib, ... }:
{
  options = with lib; {
    sane.root-on-tmpfs = mkOption {
      default = false;
      type = types.bool;
      description = "define / fs root to be a tmpfs. make sure to mount some other device to /nix";
    };
  };

  config = lib.mkIf config.sane.root-on-tmpfs {
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "mode=755"
        "size=1G"
        "defaults"
      ];
    };
  };
}
