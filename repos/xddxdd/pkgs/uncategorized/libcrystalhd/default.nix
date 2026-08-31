{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libcrystalhd";
  version = "0-unstable-2021-01-26";
  src = fetchFromGitHub {
    owner = "dbason";
    repo = "crystalhd";
    rev = "af931d9ae5a63adfefe398defb99f225ae181c24";
    hash = "sha256-5fsezV8OQjCKSr3m4jgEVMQhOfvfryBazWHeTcaUzUE=";
  };
  sourceRoot = "source/linux_lib/libcrystalhd";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '$(DESTDIR)/usr/' '$(DESTDIR)/' \
      --replace-fail "-msse2" ""
  '';

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "LIBDIR=/lib"
  ];

  outputs = [
    "out"
    "firmware"
  ];

  postFixup = ''
    mkdir -p $firmware/lib
    mv $out/lib/firmware $firmware/lib/firmware
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/dbason/crystalhd";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Broadcom Crystal HD Hardware Decoder (BCM70012/70015) userspace library";
    homepage = "https://launchpad.net/ubuntu/+source/crystalhd";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
})
