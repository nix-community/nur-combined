{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.41.1-unstable-2025-10-02";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "66620ae1349979b7564c3d71e6316cd8cc1494c6";
    hash = "sha256-5+w/A1QE6KBCSCIjINCqdeYWxkvLBd+GXbUMYd/+n7k=";
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

  meta =
    prev.meta
    // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/stephenafamo/bob/commits/${final.src.rev}/";
    };
})
