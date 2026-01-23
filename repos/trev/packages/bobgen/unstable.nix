{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-01-22";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "4f2e7617cb7e55de6f50de6e57516d84eb12401f";
      hash = "sha256-fWnqmdxyP0XpR9HwJUaZ9/mR5LolG49yHBui8wJ+ynA=";
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
