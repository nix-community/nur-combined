{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn, leveldb, geos }:

buildGoPackage rec {
  name = "imposm-${version}";
  version = "2019-02-08";
  rev = "37464958ac6a88ddeb0cc8eb7da7ed59dd4017da";

  buildInputs = [ leveldb geos ];

  goPackagePath = "github.com/omniscale/imposm3";
  goDeps = ./deps.nix;

  src = fetchgit {
    inherit rev;
    url = "https://github.com/omniscale/imposm3";
    sha256 = "1l8wz3b549vjx3axs6ngmwqrc51d5iwhk94p5ngrm5v966mdlni9";
  };
}


