{
  stdenv,
  sources,
  lib,
  autoreconfHook,
  bcg729,
  asterisk,
}:
stdenv.mkDerivation rec {
  inherit (sources.asterisk-g72x) pname version src;

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [
    asterisk
    bcg729
  ];

  patches = [ ./remove-march.patch ];

  configureFlags = [ "--with-bcg729" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled)";
    homepage = "https://github.com/arkadijs/asterisk-g72x";
    license = lib.licenses.unfreeRedistributable;
  };
}
