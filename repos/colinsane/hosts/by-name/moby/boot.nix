# USAGE:
# - nix-build -A hosts.moby-min.config.system.build.boot
# - rsync -arv ./result/ SD/
# - /nix/store/i2hh0lv8zir29yvcis2d6pmwaw9n35dm-android-tools-35.0.2/bin/fastboot boot /nix/store/irbyqxkxv75qsvy1l132zcg3rhwxxh88-ablPayloadPocophone
{ config, lib, pkgs, ... }:
let
  loader-conf = pkgs.writeText "loader.conf" ''
    timeout 5
    default entry1.conf
    console-mode keep
  '';
  entry1 = pkgs.writeText "entry1.conf" ''
    title NixOS
    version entry1
    linux /EFI/nixos/nixos-kernel
    initrd /EFI/nixos/nixos-initrd
    options init=${config.system.build.toplevel}/init ${lib.concatStringsSep " " config.boot.kernelParams}
    machine-id d44c4fd8d7ac57f9154d88526e9a6e20
    devicetree /EFI/nixos/nixos-dtb
    sort-key nixos
  '';
  entry-pmos = pkgs.writeText "entry-pmos.conf" ''
    title postmarketOS (fallback)
    version pmos
    linux /EFI/nixos/nixos-kernel
    initrd /EFI/pmos/pmos-initrd
    options splash plymouth.ignore-serial-consoles plymouth.prefer-fbcon console=ttyMSM0,115200 pmos_boot_uuid=861646c1-a4f2-45ff-8c71-ab112 loglevel=7
    machine-id d44c4fd8d7ac57f9154d88526e9a6e20
    devicetree /EFI/nixos/nixos-dtb
    sort-key pmos
  '';
  pmos-boot = pkgs.fetchurl {
    url = "https://images.postmarketos.org/bpo/edge/xiaomi-beryllium/phosh/20260815-0022/20260815-0022-postmarketOS-edge-phosh-32-xiaomi-beryllium-tianma-boot.img.xz";
    hash = "sha256-jZZxIJv0oAO8BJAfwem5ZCRfwrjVNY9MubbyUDdotsQ=";
  };
  pmos-initrd = pkgs.runCommand "pmos-initrd" { } ''
    mkdir -p $out
    ${pkgs.buildPackages.xz}/bin/xz --decompress --stdout ${pmos-boot} > boot.img
    ${pkgs.buildPackages.python3}/bin/python3 - boot.img "$TMPDIR/ramdisk.zst" <<'PY'
    import struct
    import sys

    image_path, ramdisk_path = sys.argv[1:]
    image = open(image_path, "rb").read()
    if image[:8] != b"ANDROID!":
        raise SystemExit("not an Android boot image")
    kernel_size, _, ramdisk_size, _, _, _, _, page_size, _, _ = struct.unpack_from("<10I", image, 8)
    ramdisk_offset = page_size + (kernel_size + page_size - 1) // page_size * page_size
    ramdisk = image[ramdisk_offset:ramdisk_offset + ramdisk_size]
    if len(ramdisk) != ramdisk_size:
        raise SystemExit("truncated Android boot image ramdisk")
    open(ramdisk_path, "wb").write(ramdisk)
    PY
    ${pkgs.buildPackages.zstd}/bin/zstd --decompress --stdout "$TMPDIR/ramdisk.zst" > $out/pmos-initrd
  '';
in
{
  system.build.boot = pkgs.runCommand "boot" {
  } ''
    mkdir -p $out/loader
    cp ${loader-conf} $out/loader/loader.conf

    mkdir -p $out/loader/entries
    cp ${entry1} $out/loader/entries/entry1.conf
    cp ${entry-pmos} $out/loader/entries/entry-pmos.conf

    # Artifacts extracted from postmarketOS releases live under EFI/pmos.
    mkdir -p $out/EFI/pmos
    cp ${pmos-initrd}/pmos-initrd $out/EFI/pmos/pmos-initrd

    # Artifacts built by Nix live under EFI/nixos.
    mkdir -p $out/EFI/nixos
    cp ${config.boot.kernelPackages.kernel}/Image $out/EFI/nixos/nixos-kernel
    cp ${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name} $out/EFI/nixos/nixos-dtb
    cp ${config.system.build.initialRamdisk}/initrd $out/EFI/nixos/nixos-initrd

    mkdir -p $out/EFI/BOOT
    cp ${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootaa64.efi $out/EFI/BOOT/BOOTAA64.EFI
  '';
}
