{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "ape-${version}";
  version = "0.1.1";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/ape";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "ape";
    sha256 = "0gz329a9ym4yyh9m7c563axaa833gdhh8xfr8a521djzh5snynsq";
  };

  meta = {
    description = "a git mirror *upstream* updater ";
    homepage = "https://github.com/vdemeester/ape";
    licence = lib.licenses.asl20;
  };
}
