{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-09-23";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "a318efb6d2f82684b7c5a807b4f0db9eba575ca1";
    hash = "sha256-hu1GZ4MzpySc2b5XoUS+rMwWVcSAyFTKImTkwFCy82o=";
  };

  passthru =
    prev.passthru
    // {
      updateScript = lib.concatStringsSep " " (nix-update-script {
        extraArgs = [
          "--commit"
          "--version=branch=main"
          "${final.pname}"
        ];
      });
    };

  meta =
    prev.meta
    // {
      description = "${prev.meta.description} - main branch";
      changelog = "https://github.com/Mic92/nix-update/commits/${final.src.rev}/";
    };
})
