{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.12.0-unstable-2025-08-06";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "0a4c80d8a661e2c08078c07a1fd1d1aaa5755365";
    hash = "sha256-qQp2pDfnSttnNyU6oWtb8eK10gAdGJq0Gkbdz/dySvg=";
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
