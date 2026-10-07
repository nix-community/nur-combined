{
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  cmake,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  rustPlatform.buildRustPackage (finalAttrs: {
    pname = "orb";
    inherit (ver) version;

    src = fetchFromGitHub (lib.helper.getSingle ver);

    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    cargoBuildFlags = ["--package" "orb-cli"];

    nativeBuildInputs = [cmake pkg-config];

    doCheck = false;

    meta = {
      description = "Modern and powerful HTTP client for the command line, with HTTP/1.1, HTTP/2, HTTP/3 and WebSocket support";
      homepage = "https://orb-tools.com";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "orb";
    };
  })
