{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "sec-${version}";
  version = "0.1.0";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/sec";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "sec";
    sha256 = "13w5znsm2vj3ycnrhwvg4s6sj4712rlmh0q3mvz8lf7jd4njn88x";
  };

  meta = {
    description = "Sec § — a golang opiniated dependency updater";
    homepage = "https://github.com/vdemeester/sec";
    license = lib.licenses.asl20;
  };
}
