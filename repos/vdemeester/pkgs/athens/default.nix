{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "athens-${version}";
  version = "0.2.0";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "0cax1p4hgazaxv7bw61m2l04gzixh46r2blrdi39nddqfh6x2pis";
  };

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    licence = lib.licenses.mit;
  };
}
