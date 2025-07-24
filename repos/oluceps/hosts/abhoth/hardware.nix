{
  config,
  inputs,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    # kernelModules = [ "brutal" ];
    # extraModulePackages = with config.boot.kernelPackages; [
    #   (callPackage "${inputs.self}/pkgs/kernel-module/tcp-brutal/package.nix" { })
    # ];
    loader = {
      timeout = 3;
      grub.enable = false;
      limine = {
        enable = true;
        efiSupport = false;
        biosSupport = true;
        biosDevice = "/dev/vda";
        maxGenerations = 3;
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
      "console=ttyS0"
      "earlyprintk=ttyS0"
      "rootdelay=300"
      "19200n8"
    ];
    initrd = {
      compressor = "zstd";
      compressorArgs = [
        "-19"
        "-T0"
      ];
      systemd.enable = true;
    };

  };
}
