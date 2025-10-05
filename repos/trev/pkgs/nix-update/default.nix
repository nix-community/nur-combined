{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-10-05";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "d3567d8f86e94d82ce1895aeeadeff2cf89ec35f";
    hash = "sha256-Ux/AZ+JpJwH4AL0CgokCcCRjBnNqbjekjIf5xF0IrCA=";
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
