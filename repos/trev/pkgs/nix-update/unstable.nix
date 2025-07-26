{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.11.0-unstable-2025-07-25";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "5fce80c5e40a029269cd515ebd9ed3ebcf5d2701";
    hash = "sha256-LrjF/8LDsZF3Xh1R4u6xfBEMwz0TZMyU82VUJvwD4/c=";
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
