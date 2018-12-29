{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "esc-unstable-${version}";
  version = "2018-11-20";
  rev = "e93e776f8cb66a6bdcdf1afbef94460c0a62d7d9";

  goPackagePath = "github.com/mjibson/esc";

  src = fetchFromGitHub {
    inherit rev;
    owner = "mjibson";
    repo = "esc";
    sha256 = "1d3lwl5m07hx6i1zww5gbhsnml98r482vcl7ijgsppy113jmh26k";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "A simple file embedder for Go";
    homepage = "https://github.com/mjibson/esc";
    license = lib.licenses.asl20;
  };
}
