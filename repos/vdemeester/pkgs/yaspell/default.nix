{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "yaspell-${version}";
  version = "1.0.4";
  rev = "${version}";

  goPackagePath = "github.com/vodkabears/yaspell";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vodkabears";
    repo = "yaspell";
    sha256 = "0mjsf10qwz3p88ynndcm6ss62kmb7ca45k95xjqp5p02xgqssn0y";
  };

  meta = {
    description = "Spell checking tool for various texts written in golang";
    homepage = https://github.com/vodkabears/yaspell;
    license = lib.licenses.mit;
  };
}
