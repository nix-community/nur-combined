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
stdenv.mkDerivation {
  name = "aic8800";
  version = aic8800-firmware.version;
  src = aic8800-firmware.src;

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ dpkg ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  outputs = [ "out" ] ++ varient;

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
}
