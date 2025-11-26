{
  bobgen,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
bobgen.overrideAttrs (
  final: prev: {
    version = "0.42.0-unstable-2025-11-25";

    src = fetchFromGitHub {
      owner = "stephenafamo";
      repo = "bob";
      rev = "8e41efed4f7ea4782ee7c2d06e2643967cce71d7";
      hash = "sha256-reTvQDUqsRmdl0RyCWoUoF8dc/ZrSZxR8x8++VC4H3A=";
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
