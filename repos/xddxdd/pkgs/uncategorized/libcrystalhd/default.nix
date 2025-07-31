{
  stdenv,
  lib,
  sources,
}:
stdenv.mkDerivation rec {
  pname = "libcrystalhd";
  inherit (sources.crystalhd) version src;
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

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Broadcom Crystal HD Hardware Decoder (BCM70012/70015) userspace library";
    homepage = "https://launchpad.net/ubuntu/+source/crystalhd";
    license = lib.licenses.unfreeRedistributable;
  };
}
