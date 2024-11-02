{
  stdenv,
  lib,
  fetchurl,
  kernel,
}:
stdenv.mkDerivation rec {
  pname = "ast";
  version = "1.14.3_3";
  src = fetchurl {
    url = "https://www.aspeedtech.com/file/support/Linux_DRM_${version}.tar.gz";
    sha256 = "sha256-96qFI5zYXxzC/dhyueWVSVwl60ytDBb4iiH6E/E9uRk=";
    # Aspeed website has certificate issues
    curlOptsList = [ "-k" ];
  };

  sourceRoot = "Linux_DRM_${version}/sources/src66";
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
    description = "Aspeed Graphics Driver";
    homepage = "https://www.aspeedtech.com/support_driver/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
