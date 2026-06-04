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
  inherit (sources.dnsproxy) pname version src;

  vendorHash = "sha256-tyEp0vY8hWE8jTvkxKuqQJcgeey+c50pxREpmlZWE24=";

  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/AdguardTeam/dnsproxy/internal/version.version=${sources.dnsproxy.version}"
  ];

  # Development tool dependencies; not part of the main project
  excludedPackages = [ "internal/tools" ];

  doCheck = false;

  meta = with lib; {
    description = "Simple DNS proxy with DoH, DoT, and DNSCrypt support";
    homepage = "https://github.com/AdguardTeam/dnsproxy";
    license = licenses.asl20;
    maintainers = with maintainers; [
      contrun
      diogotcorreia
    ];
    mainProgram = "dnsproxy";
  };
}
