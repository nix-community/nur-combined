{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
  ...
}:
stdenv.mkDerivation rec {
  name = "acpi_ec";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "musikid";
    repo = "acpi_ec";
    rev = "v${version}";
    sha256 = "sha256-RyBr9g2ho/TdLkFKAH+YnILtO4kS/nGhQUeYeextYY8=";
  };

  sourceRoot = "source/src";
  hardeningDisable = ["pic" "format"];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  inherit (kernel) makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = ["modules_install"];
}
