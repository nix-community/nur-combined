{
  stdenv,
  lib,
  sources,
  kernel,
}:
stdenv.mkDerivation rec {
  inherit (sources.nft-fullcone) pname version src;
  sourceRoot = "source/src";

  patches = [ ./nft-fullcone.patch ];

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  inherit (kernel) makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Nftables fullcone expression kernel module";
    homepage = "https://github.com/fullcone-nat-nftables/nft-fullcone";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
