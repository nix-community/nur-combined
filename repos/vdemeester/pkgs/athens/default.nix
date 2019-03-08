{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "athens-${version}";
  version = "0.3.0";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "1pilffrnlic6ic9msjkdnhmnwji0zjxfkfmldybhsry2r4j9xwnd";
  };

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
