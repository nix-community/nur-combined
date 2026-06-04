{
  fetchurl,
  fetchFromGitHub,
  dockerTools,
  fetchgit,
  stdenvNoCC,
}:
let
  sources = import ../../_sources/generated.nix {
    inherit
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };
in
stdenvNoCC.mkDerivation {
  inherit (sources.metacubexd) pname version src;
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';
}
