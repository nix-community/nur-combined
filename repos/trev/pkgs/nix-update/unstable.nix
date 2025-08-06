{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.12.0-unstable-2025-08-05";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "09aadb5d6d9e1fc57df0b61def4bdd8b43ea47a1";
    hash = "sha256-zumHGR/7NqlkSi8W7Vvdka/l/8x1aenpINg2jqepyeo=";
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
