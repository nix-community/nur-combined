{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "athens-${version}";
  version = "0.8.1";
  rev = "v${version}";

  goPackagePath = "github.com/gomods/athens";
  subPackages = [ "cmd/proxy" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "gomods";
    repo = "athens";
    sha256 = "16ilzxmpwarf0c7195bfqn3ir3s6dkqma4bhjx57amswmkjjrqfp";
  };
  modSha256 = "0nad3k01a58xj21sj4m0ydv5m64w3klkgzbdvbx9szy298wq1w18";

  meta = {
    description = "a Go module datastore and proxy";
    homepage = "https://github.com/godmods/athens";
    license = lib.licenses.mit;
  };
}
