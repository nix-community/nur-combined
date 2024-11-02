{
  stdenv,
  lib,
  sources,
  kernel,
}:
stdenv.mkDerivation rec {
  inherit (sources.nullfsvfs) pname version src;

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  patches = [ ./nullfsvfs-change-reported-free-space.patch ];

  inherit (kernel) makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Virtual black hole file system that behaves like /dev/null";
    homepage = "https://github.com/abbbi/nullfsvfs";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
