{ pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader = {
      timeout = 3;
      grub.enable = false;
      limine = {
        enable = true;
        efiSupport = false;
        biosSupport = true;
        biosDevice = "/dev/vda";
      };
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
