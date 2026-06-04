{
  lib,
  makeRustPlatform,
  fenix,
  fetchurl,
  fetchgit,
  fetchFromGitHub,
  dockerTools,
}:

let
  inherit (fenix.minimal) toolchain;
  sources = import ../../_sources/generated.nix {
    inherit
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    inherit (sources.phantun) pname version src;

    cargoLock = sources.phantun.cargoLock."Cargo.lock";

    meta = {
      description = "Transforms UDP stream into (fake) TCP streams that can go through Layer 3 & Layer 4 (NAPT) firewalls/NATs";
      homepage = "https://github.com/dndx/phantun";
      license = with lib.licenses; [
        asl20
        mit
      ];
      maintainers = with lib.maintainers; [ oluceps ];
      mainProgram = "phantun";
    };
  }
