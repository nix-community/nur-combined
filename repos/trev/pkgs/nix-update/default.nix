{
  nix-update,
  fetchFromGitHub,
  nix-update-script,
  lib,
  ...
}:
nix-update.overrideAttrs
(final: prev: {
  version = "1.13.1-unstable-2025-10-12";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-update";
    rev = "1fe84000b8e3ea5975e9526ba04f389bd29ee0bb";
    hash = "sha256-lXgGEK8KVJxX8H/TOCF6V25mO1mMXDZ1zfwbJ5Pc3Cg=";
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
