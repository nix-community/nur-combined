{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, buildGoPackage ? pkgs.buildGoPackage
, ...
}:
with pkgs;
buildGoPackage rec {
  name = "sync3c-v${version}";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "muesli";
    repo = "sync3c";
    rev = "v0.1";
    sha256 = "0bpq2j5x534q253ywwlwyiqnlb321k7v9j3lpcifcv08p848y8v0";
  };

  goPackagePath = "github.com/muesli/sync3c";

  goDeps = ./deps.nix;

  buildFlags = "--tags release";

  meta = with lib; {
    description = "A little tool to sync/download media from https://media.ccc.de";
    homepage = https://github.com/muesli/sync3c;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
