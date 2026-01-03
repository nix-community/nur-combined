{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.default ];
  disko.devices.disk.blarg = {
    device = "/dev/disk/by-id/nvme-Micron_2400_MTFDKBK2T0QFM_230341951668_1-part11";
    content = {
      type = "luks";
      name = "nixos-crypted";
      settings.allowDiscards = true;
      # no keyFile; interactive
      content = {
        type = "btrfs";
        # extraArgs = [ "-f" ];
        subvolumes = {
          "/root" = {
            mountpoint = "/";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
          "/home" = {
            mountpoint = "/home";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
          "/nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };
    };
  };
}
