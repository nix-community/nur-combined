{ stdenv, lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  name = "buildkit-${version}";
  version = "0.7.1";
  rev = "v${version}";

  goPackagePath = "github.com/moby/buildkit";
  subPackages = [ "cmd/buildctl" "cmd/buildkitd" ];
  buildFlagsArray = let t = "${goPackagePath}/version"; in
    ''
      -ldflags=
        -X ${t}.Version=${version}
    '';

  src = fetchFromGitHub {
    inherit rev;
    owner = "moby";
    repo = "buildkit";
    sha256 = "048h69ffgmpir2ix9ldi6zrzlwxa5yz3idg5ajspz2dihmzmnwws";
  };

  meta = {
    description = "concurrent, cache-efficient, and Dockerfile-agnostic builder toolkit";
    homepage = https://github.com/moby/buildkit;
    license = lib.licenses.asl20;
  };
}
