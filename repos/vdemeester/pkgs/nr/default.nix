{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "nr-${version}";
  version = "0.1.1";
  rev = "v${version}";

  goPackagePath = "github.com/vdemeester/nr";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vdemeester";
    repo = "nr";
    sha256 = "0hs6llm7bahwabgspsjyr6dy4w9ibfrrmjakln3ipfk6iamhqwxh";
  };

  meta = {
    description = "a nix run alias generator";
    homepage = "https://github.com/vdemeester/nr";
    license = lib.licenses.asl20;
  };
}
