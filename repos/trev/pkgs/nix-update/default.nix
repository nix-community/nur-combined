{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.0-unstable-2025-09-22";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "4f23e1b2735ec226343ca1c3db91748e88440167";
    hash = "sha256-Zity8xKhlZmUw+Jf6ZA61bxNvhXQK1issriH01dXqqM=";
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
