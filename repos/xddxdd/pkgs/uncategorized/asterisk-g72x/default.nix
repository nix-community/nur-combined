{
  stdenv,
  sources,
  lib,
  autoreconfHook,
  bcg729,
  asterisk,
  ...
}@args:
stdenv.mkDerivation rec {
  inherit (sources.asterisk-g72x) pname version src;

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [
    asterisk
    bcg729
  ];

  patches = [ ./remove-march.patch ];

  configureFlags = [ "--with-bcg729" ];

  meta = with lib; {
    description = "G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled)";
    homepage = "https://github.com/arkadijs/asterisk-g72x";
    license = licenses.unfreeRedistributable;
  };
}
