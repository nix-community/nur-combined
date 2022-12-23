{ sources
, stdenv
, lib
, ...
} @ args:

stdenv.mkDerivation {
  inherit (sources.nbfc-linux-lantian) pname version src;

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "NoteBook FanControl ported to Linux (with Lan Tian's modifications)";
    homepage = "https://github.com/xddxdd/nbfc-linux";
    license = licenses.gpl3;
  };
}
