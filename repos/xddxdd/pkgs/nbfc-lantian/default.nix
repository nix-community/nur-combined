{ stdenv
, fetchFromGitHub
, lib
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "nbfc-lantian";
  version = "a11959cccc3fe1ef55e9ddd01ac2c4ae142eae00";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "nbfc-linux";
    rev = version;
    sha256 = "sha256-FDi/zLrHEVleCrGoZ8Y7JJ+Av9u0e+2OB5FEwWGx6rI=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "NoteBook FanControl ported to Linux (with Lan Tian's modifications)";
    homepage = "https://github.com/xddxdd/nbfc-linux";
    license = licenses.gpl3;
  };
}
