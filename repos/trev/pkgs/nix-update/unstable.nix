{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.11.0-unstable-2025-07-24";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "65663d259920796fc6845d700cc44afa23a697ec";
    hash = "sha256-xQp4aaSLuk0RNbEo5xriA1r9/QzGxoZzvX2ggDWjgPU=";
  };

  passthru =
    prev.passthru
    // {
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
      changelog = "https://github.com/Mic92/nix-update/commits/${final.src.rev}/";
    };
})
