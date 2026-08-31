{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
  autoreconfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "crystalhd";
  version = "0-unstable-2021-01-26";
  src = fetchFromGitHub {
    owner = "dbason";
    repo = "crystalhd";
    rev = "af931d9ae5a63adfefe398defb99f225ae181c24";
    hash = "sha256-5fsezV8OQjCKSr3m4jgEVMQhOfvfryBazWHeTcaUzUE=";
  };
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
    makeFlags="$makeFlags -C ${finalAttrs.KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/dbason/crystalhd";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Broadcom Crystal HD Hardware Decoder (BCM70012/70015) driver";
    homepage = "https://github.com/dbason/crystalhd";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
})
