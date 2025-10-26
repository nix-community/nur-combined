{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-10-26";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "cb67d1603df73b893e48eb0d4da5e25502041d48";
    hash = "sha256-r7CSwiu+DkSmt62RxxnGQw1pEmYYV7OyLv8wrR3eRSE=";
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
