{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.41.1-unstable-2025-10-16";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "96da65fd88a50ae532079e8ea69746183f4af3a1";
      hash = "sha256-S+gRQB69c/yCHhH7IC0j3HEyQxmosFkNeMM2kRvcXlA=";
    };

    vendorHash = "sha256-Jqlah37+tfNqsgeL/MnbVUmSfU2JWMJDb9AQrEqXnXU=";

    passthru = {
      updateScript = lib.concatStringsSep " " (nix-update-script {
        extraArgs = [
          "--commit"
          "--version=branch=main"
          "${final.pname}.unstable"
        ];
      });
    };

    meta = prev.meta // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
  }
)
