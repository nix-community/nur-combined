{
  lib,
  stdenv,
  pins,
  pkg-config,
  glib,
  chromium,
}:
stdenv.mkDerivation {
  pname = "chromium-launcher";
  version = pins.chromium-launcher.rev;

  src = pins.chromium-launcher.outPath;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  buildFlags = [
    "CHROMIUM_BINARY=${chromium}/bin/chromium"
  ];

  installFlags = [
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "Chromium launcher with support for custom user flags";
    homepage = "https://github.com/foutrelis/chromium-launcher";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = licenses.isc;
    priority = (chromium.meta.priority or 0) - 1;
  };
}
