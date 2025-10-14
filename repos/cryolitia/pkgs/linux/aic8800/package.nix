{
  lib,
  pkgs,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  dpkg,
#  aic8800-firmware,
}:
let
  aic8800-firmware = pkgs.callPackage ../../by-name/aic8800-firmware/package.nix { };
  varient = [
    "pcie"
    "sdio"
    "usb"
  ];
in
stdenv.mkDerivation (finalAttr: {
  name = "aic8800";
  version = aic8800-firmware.version;
  src = aic8800-firmware.src;

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ dpkg ];

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  outputs = [ "out" ] ++ varient;

  patchPhase = ''
    runHook prePatch

    # Apply all patches in debian/patches
    dpkg-source --before-build .

    find ./src -name "Makefile" -exec echo Fixing... {} \; -exec sed -i 's/CONFIG_USE_FW_REQUEST ?= n/CONFIG_USE_FW_REQUEST ?= y/g' {} \;
    find ./src -name "Makefile" -exec echo Fixing... {} \; -exec sed -i 's/CONFIG_USE_FW_REQUEST = n/CONFIG_USE_FW_REQUEST = y/g' {} \;
    sed -i 's|fw_patch_table_8800d80_u02.bin|aic8800_fw/USB/aic8800D80/fw_patch_table_8800d80_u02.bin|g' src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_compat_8800d80.h
    sed -i 's|fw_adid_8800d80_u02.bin|aic8800_fw/USB/aic8800D80/fw_adid_8800d80_u02.bin|g' src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_compat_8800d80.h
    sed -i 's|fw_patch_8800d80_u02.bin|aic8800_fw/USB/aic8800D80/fw_patch_8800d80_u02.bin|g' src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_compat_8800d80.h
    sed -i 's|fw_patch_8800d80_u02_ext|aic8800_fw/USB/aic8800D80/fw_patch_8800d80_u02_ext|g' src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_compat_8800d80.h
    sed -i 's|fmacfw_8800d80_u02.bin|aic8800_fw/USB/aic8800D80/fmacfw_8800d80_u02.bin|g' src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_compat_8800d80.h
    sed -i 's|aic_userconfig_8800d80.txt|aic8800_fw/USB/aic8800D80/aic_userconfig_8800d80.txt|g' src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_compat_8800d80.h
    

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    make $makeFlags M="$PWD"/src/PCIE/driver_fw/driver/aic8800/aic8800_fdrv
    make $makeFlags M="$PWD"/src/SDIO/driver_fw/driver/aic8800
    make $makeFlags M="$PWD"/src/USB/driver_fw/drivers/aic8800
    make $makeFlags M="$PWD"/src/USB/driver_fw/drivers/aic_btusb

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -pv $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/
  ''
  + lib.strings.concatLines (
    lib.lists.forEach varient (
      name:
      let
        directory = "lib/modules/${kernel.modDirVersion}/kernel/drivers/aic8800_${lib.strings.toUpper name}";
      in
      ''
        find ./src/"${lib.strings.toUpper name}"/ -name "*.ko" -exec install {} -Dm444 -v -t ${placeholder name}/${directory} \;
        ln -sv ${placeholder name}/${directory} $out/${directory}
      ''
    )
  )
  + ''

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/radxa-pkg/aic8800";
    description = "Aicsemi aic8800 Wi-Fi driver";
    # https://github.com/radxa-pkg/aic8800/issues/54
    license = with lib.licenses; [
      gpl2Only
    ];
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.linux;
  };
})
