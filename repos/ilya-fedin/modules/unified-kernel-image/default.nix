{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.boot.loader.unifiedKernelImage;

  efi = config.boot.loader.efi;

  builder = pkgs.substituteAll {
    src = ./builder.sh;
    isExecutable = true;
    inherit (pkgs) bash;
    path = [pkgs.coreutils pkgs.gnused pkgs.binutils-unwrapped];
    systemd = config.systemd.package;
    inherit (efi) efiSysMountPoint;
  };
in

{
  options = {
    boot.loader.unifiedKernelImage = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          A unified kernel image is a single EFI PE executable combining an EFI stub loader,
          a kernel image, an initramfs image, and the kernel command line.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    boot.loader.grub.enable = mkDefault false;
    system.build.installBootLoader = builder;
    system.boot.loader.id = "unifiedKernelImage";
  };
}
