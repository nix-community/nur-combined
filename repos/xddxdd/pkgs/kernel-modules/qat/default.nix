{
  stdenv,
  sources,
  lib,
  kernel,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.qat) pname src;
  version = lib.removePrefix "QAT.L." (builtins.elemAt (lib.splitString "/" sources.qat.version) 1);

  sourceRoot = ".";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  patches = [ ./fix-build-without-pcieaer.patch ];

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  preConfigure = ''
    cd quickassist/qat
  '';

  inherit (kernel) makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  # meta = {
  #   maintainers = with lib.maintainers; [ xddxdd ];
  #   description = "Aspeed Graphics Driver";
  #   homepage = "https://www.aspeedtech.com/support_driver/";
  #   license = lib.licenses.unfree;
  #   platforms = lib.platforms.linux;
  # };
}
