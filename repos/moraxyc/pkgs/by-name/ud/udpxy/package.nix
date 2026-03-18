{
  lib,
  stdenv,

  sources,
  source ? sources.udpxy,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  sourceRoot = "${finalAttrs.src.name}/chipmunk";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '-Werror ' ""
  '';

  installTargets = "install-strip";
  installFlags = [
    "DESTDIR=$(out)"
    "MANPAGE_DIR=$(out)/share/man/man1"
    "PREFIX="
    "GZIP=gzip"
    "STRIP=strip"
  ];

  doCheck = false; # no test

  meta = {
    description = "Lightweight network-traffic relay daemon";
    homepage = "https://github.com/pcherenkov/udpxy";
    license = lib.licenses.gpl3Plus;
    mainProgram = "udpxy";
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
