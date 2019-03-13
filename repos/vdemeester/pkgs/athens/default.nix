{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "athens-${version}";
  version = "0.3.1";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "1kmdrhc40y3766msx8k3lk2dw691d9lyxavg7p8p6xnw6gcl3b9j";
  };

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
