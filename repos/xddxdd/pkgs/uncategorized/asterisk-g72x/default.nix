{ stdenv
, sources
, lib
, autoreconfHook
, bcg729
, asterisk
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.asterisk-g72x) pname version src;

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ asterisk bcg729 ];
  configureFlags = [
    "--with-bcg729"
  ];

  preAutoreconf = ''
    sed -i "s/march=native/march=x86-64/g" configure.ac
  '';

  meta = with lib; {
    description = "G.729 and G.723.1 codecs for Asterisk (Only G.729 is enabled)";
    homepage = "https://github.com/arkadijs/asterisk-g72x";
    license = licenses.unfreeRedistributable;
  };
}
