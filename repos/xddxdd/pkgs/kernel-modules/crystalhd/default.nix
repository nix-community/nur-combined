{
  stdenv,
  lib,
  sources,
  kernel,
  autoreconfHook,
}:
stdenv.mkDerivation rec {
  inherit (sources.crystalhd) pname version src;

  patches = [ ./fix.patch ];

  postPatch = ''
    cd driver/linux

    substituteInPlace Makefile.in \
      --replace-fail "EXTRA_CFLAGS" "ccflags-y" \
      --replace-fail "-Werror" ""
  '';

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ autoreconfHook ];

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Broadcom Crystal HD Hardware Decoder (BCM70012/70015) driver";
    homepage = "https://github.com/dbason/crystalhd";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
}
