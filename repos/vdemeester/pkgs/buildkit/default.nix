{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  name = "buildkit${version}";
  version = "0.3.3";
  rev = "v${version}";

  goPackagePath = "github.com/moby/buildkit";
  subPackages = [ "cmd/buildctl" "cmd/buildkitd" ];

  src = fetchFromGitHub {
    inherit rev;
    owner = "moby";
    repo = "buildkit";
    sha256 = "06d79k6s19fsv80fp9wprxxr1yrgzwyfhb7ccwgk4dbs5iaghd68";
  };

  meta = {
    description = "concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit";
    homepage = https://github.com/moby/buildkit;
    license = lib.licenses.asl20;
  };
}
