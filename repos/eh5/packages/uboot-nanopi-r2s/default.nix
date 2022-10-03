{ buildUBoot, armTrustedFirmwareRK3328 } @ args:
let
  armTrustedFirmwareRK3328 = args.armTrustedFirmwareRK3328.overrideAttrs (_: {
    NIX_LDFLAGS = "--no-warn-execstack --no-warn-rwx-segments";
    enableParallelBuilding = true;
  });
in
buildUBoot {
  defconfig = "nanopi-r2s-rk3328_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  BL31 = "${armTrustedFirmwareRK3328}/bl31.elf";
  enableParallelBuilding = true;
  filesToInstall = [ "u-boot.itb" "idbloader.img" ];
}
