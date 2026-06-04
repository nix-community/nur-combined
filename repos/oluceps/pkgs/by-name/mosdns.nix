{
  lib,
  buildGoModule,
  fetchurl,
  fetchgit,
  fetchFromGitHub,
  dockerTools,
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
buildGoModule {
  inherit (sources.mosdns) pname version src;

  vendorHash = "sha256-0J5hXb1W8UruNG0KFaJBOQwHl2XiWg794A6Ktgv+ObM=";
  doCheck = false;
  ldflags = [
    "-s"
    "-w"
  ];
  meta = with lib; {
    description = "A DNS proxy server";
    homepage = "https://github.com/IrineSistiana/mosdns";
    license = licenses.gpl3;
  };
}
