{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "athens-${version}";
  version = "0.4.0";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "0npiyhdjg9aka4ii7dhmy91vbxm5h81ncp2gmszj7zy0niiclf9y";
  };

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
