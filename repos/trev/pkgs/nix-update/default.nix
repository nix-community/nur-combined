{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-10-02";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "e70d4320876ca4f39242783b4dd439dddbb8e9cf";
    hash = "sha256-UdtfXMo1LZHYNFblXmqBzGPEqlLU9vhN3PJfTjMe3PI=";
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
