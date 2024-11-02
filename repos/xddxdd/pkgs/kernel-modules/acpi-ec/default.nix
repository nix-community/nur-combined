{
  stdenv,
  lib,
  sources,
  kernel,
}:
stdenv.mkDerivation rec {
  inherit (sources.acpi-ec) pname version src;

  sourceRoot = "source/src";
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
    description = "Kernel module to access directly to the ACPI EC";
    homepage = "https://github.com/musikid/acpi_ec";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
