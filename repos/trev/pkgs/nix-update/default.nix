{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-11-02";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "d0850c486c97aade4d48e018862c42cdf64e9ae4";
    hash = "sha256-ylpKsYdEKL1MrI/FrnQ/EDSd/BSYlmuHM/+UUDzaDJw=";
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
