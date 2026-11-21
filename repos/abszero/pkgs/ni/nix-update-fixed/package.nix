{
  lib,
  nix-update,
  writeShellApplication,
}:

let
  patchedNixUpdate = nix-update.overridePythonAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./flake-archive.patch ];
  });
in

writeShellApplication {
  name = "nix-update";
  text = ''
    unset PYTHONPATH
    exec ${lib.getExe patchedNixUpdate} "$@"
  '';

  meta = {
    description = "nix-update with reliable flake source realization";
    mainProgram = "nix-update";
  };
}
