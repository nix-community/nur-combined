{
  lib,
  pkgs,
  allInputs,
  vacuRoot,
  vacuWrappedSops,
  ...
}:
let
  configs = allInputs.self.nixosConfigurations;
  iso = configs.shel-installer-iso.config;
  pxe = configs.shel-installer-pxe.config;
  firewall = pkgs.callPackage ./firewall.nix { };
  settings = pkgs.writeText "installer-settings.json" (
    builtins.toJSON {
      isoInitrd = "${iso.system.build.initialRamdisk}/${iso.system.boot.loader.initrdFile}";
      isoContents = map (entry: {
        source = toString entry.source;
        inherit (entry) target;
      }) iso.isoImage.contents;
      isoSquashfs = toString (
        pkgs.callPackage "${pkgs.path}/nixos/lib/make-squashfs.nix" {
          storeContents = iso.isoImage.storeContents;
          comp = iso.isoImage.squashfsCompression;
        }
      );
      isoVolumeID = iso.isoImage.volumeID;
      isoBootFlags =
        lib.optionals iso.isoImage.makeBiosBootable [
          "-eltorito-boot"
          "isolinux/isolinux.bin"
          "-eltorito-catalog"
          ".boot.cat"
          "-no-emul-boot"
          "-boot-load-size"
          "4"
          "-boot-info-table"
          "--sort-weight"
          "1"
          "/isolinux"
        ]
        ++ lib.optionals (iso.isoImage.makeUsbBootable && iso.isoImage.makeBiosBootable) [
          "-isohybrid-mbr"
          "${pkgs.syslinux}/share/syslinux/isohdpfx.bin"
        ]
        ++ lib.optionals iso.isoImage.makeEfiBootable [
          "-eltorito-alt-boot"
          "-e"
          "boot/efi.img"
          "-no-emul-boot"
          "-isohybrid-gpt-basdat"
        ];
      pxeInitrd = "${pxe.system.build.netbootRamdisk}/initrd";
      pxeKernel = "${pxe.system.build.kernel}/${pxe.system.boot.loader.kernelFile}";
      pxeCmdline = "init=${pxe.system.build.toplevel}/init ${toString pxe.boot.kernelParams}";
      memtest = pkgs.memtest86plus.efi;
      pixiecore = lib.getExe pkgs.pixiecore;
      firewall = lib.getExe firewall;
      ca = "${vacuRoot}/secrets/misc/installer_ssh_ca";
      caPublic = "${vacuRoot}/temp_installer_ssh_ca.pub";
      sops = lib.getExe vacuWrappedSops;
    }
  );
in
pkgs.writeShellApplication {
  name = "make-installer";
  runtimeInputs = with pkgs; [
    python3
    openssh
    cpio
    xorriso
    coreutils
    util-linux
    systemd
  ];
  text = ''
    exec python3 ${./make-installer.py} ${settings} "$@"
  '';
}
