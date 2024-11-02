{
  sources,
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  inherit (sources.nbfc-linux-lantian) pname version src;

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "NoteBook FanControl ported to Linux (with Lan Tian's modifications)";
    homepage = "https://github.com/xddxdd/nbfc-linux";
    license = lib.licenses.gpl3Only;
  };
}
