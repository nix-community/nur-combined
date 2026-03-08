{
  lib,
  buildNpmPackage,
  fetchgit,
  nix-update-script,
  ...
}: let
  repo = "https://github.com/raycast/extensions";
in
  buildNpmPackage rec {
    pname = "bitwarden";
    version = "1.0.0";

    src = fetchgit {
      url = repo;
      rev = "b5f5c623b5f94b8ca99d2660275dfe3b1786a29a";
      sha256 = "sha256-YRayXbg3h4UTkfrpeCKeJuttAMUP1fsNqEIlX8o+no4=";
      sparseCheckout = [
        "/extensions/${pname}"
      ];
      rootDir = "/extensions/${pname}";
    };
    passthru.updateScript = nix-update-script {
      extraArgs = ["--flake" "--version=branch" "--url" repo];
    };

    npmDepsHash = "sha256-NG+2FZBqaZvWgrkBhzvkAJ8b4WaOTQoVqZ6cCu4BiZM=";

    installPhase =
      # bash
      ''
        runHook preInstall

        mkdir -p $out
        cp -r /build/.config/raycast/extensions/${pname}/* $out/

        runHook postInstall
      '';

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
    };

    meta = {
      description = "Access your Bitwarden vault directly from Raycast";
      homepage = "https://www.raycast.com/jomifepe/bitwarden";
      license = lib.licenses.mit;
    };
  }
