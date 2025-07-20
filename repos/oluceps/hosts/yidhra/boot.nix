{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      systemd-boot.enable = true;
      timeout = 1;
    };
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
      "19200n8"
      "ia32_emulation=0"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;

      kernelModules = [
        # "hv_netvsc"
        # "hv_utils"
        # "hv_storvsc"
      ];
    };
  };
}
