{
  fetchurl,
  fetchFromGitHub,
  dockerTools,
  fetchgit,
  rustPlatform,
  lib,
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
rustPlatform.buildRustPackage rec {
  inherit (sources.restls) pname version src;

  cargoLock = sources.restls.cargoLock."Cargo.lock";

  meta = with lib; {
    homepage = "https://github.com/3andne/restls";
    description = "A Perfect Impersonation of TLS";
    license = licenses.bsd3;
    mainProgram = "restls";
    maintainers = with maintainers; [ oluceps ];
  };
}
