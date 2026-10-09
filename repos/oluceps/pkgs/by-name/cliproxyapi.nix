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
  inherit (sources.cliproxyapi) pname src;
  version = lib.removePrefix "v" sources.cliproxyapi.version;

  vendorHash = "sha256-r3yWkdMcM40G9jV7MxW/qNv3E9WrHavFilW24quEf+8=";

  subPackages = [ "cmd/server" ];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  meta = with lib; {
    description = "CLIProxyAPI - A proxy API application";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    mainProgram = "cli-proxy-api";
  };
}
