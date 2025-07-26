{
  stdenv,
  lib,
  sources,
}:
stdenv.mkDerivation rec {
  inherit (sources.crystalhd) pname version src;

  # patches = [ ./fix.patch ];

  postPatch = ''
    cd linux_lib/libcrystalhd

    substituteInPlace Makefile \
      --replace-fail '$(DESTDIR)/usr/' '$(DESTDIR)/'
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
    homepage = "https://github.com/dbason/crystalhd";
    license = lib.licenses.unfreeRedistributable;
  };
}
