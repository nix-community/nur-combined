{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-09-22";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "4deaf768420525283de7b0f95abb068834c6ae91";
    hash = "sha256-b/Ymvz4Un67j7UulzBJtmKrwcchpEE/si/QOn/m8m80=";
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
