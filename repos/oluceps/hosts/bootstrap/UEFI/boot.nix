_:
{
  boot = {
    kernelParams = [
      "audit=0"
      "net.ifnames=0"

      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      systemd-boot.enable = true;
      timeout = 3;
    };
    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;

      kernelModules = [
        "hv_vmbus" # for hyper-V
        "hv_netvsc"
        "hv_utils"
        "hv_storvsc"
      ];
    };
  };
}
