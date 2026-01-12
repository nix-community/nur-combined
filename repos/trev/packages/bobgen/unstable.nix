{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2026-01-11";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "1ab321a734f1b9c99bf886f9bbff714fbef200a7";
      hash = "sha256-Vo+DyPwrxuNymlCh8jxcGJ3fQJn/TpCsNXx0pf6aI3I=";
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
