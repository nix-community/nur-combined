{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs
(final: prev: {
  version = "0.41.1-unstable-2025-09-02";

  src = fetchFromGitHub {
    owner = "stephenafamo";
    repo = "bob";
    rev = "10b9d8cfbc4b534386f6db8ed02ea61d1fc34726";
    hash = "sha256-HaWeiC1sxJz2wWYsvopD8ufFZlpMiA1GkfzrnDvP1XM=";
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
