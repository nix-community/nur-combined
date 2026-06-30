{
  lib,
  coreutils,
  crate2nix,
  nix,
  nix-update,
  writeShellApplication,
}:

(writeShellApplication {
  name = "update-crate2nix-package";
  runtimeInputs = [
    coreutils
    crate2nix
    nix
    nix-update
  ];

  text = builtins.readFile ./update.sh;

}).overrideAttrs
  (prev: {
    meta = (prev.meta or { }) // {
      description = "Script to update a crate2nix-based package's source and generated Nix expressions";
      homepage = "https://github.com/Alxandr/nur/tree/master/pkgs/update-crate2nix-package";
      license = lib.licenses.mit;
    };
  })
