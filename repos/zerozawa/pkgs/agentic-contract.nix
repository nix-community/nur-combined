{
  fetchFromGitHub,
  lib,
  rustPlatform,
}: let
  rev = "0f01fc38b490c0ac289019c188b716c34060361f";
in
rustPlatform.buildRustPackage rec {
  pname = "agentic-contract";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "agentralabs";
    repo = pname;
    inherit rev;
    hash = "sha256-c/AC1Mi791SMCGtTfOtm+8lS2MTMqxuiNUAKJ9J6SsA=";
  };

  cargoHash = "sha256-0p+aq72ElDbi4lOzlbmaPWDA7OJIp3fWRQEc6pWM2RE=";

  cargoBuildFlags = [
    "-p"
    "agentic-contract-cli"
  ];

  cargoTestFlags = cargoBuildFlags;

  cargoInstallFlags = [
    "-p"
    "agentic-contract-cli"
    "--bin"
    "acon"
  ];

  meta = with lib; {
    description = "Policy engine CLI for AI agents";
    homepage = "https://github.com/agentralabs/agentic-contract";
    license = with licenses; [mit];
    mainProgram = "acon";
    platforms = platforms.linux ++ platforms.darwin;
    sourceProvenance = with sourceTypes; [fromSource];
  };
}