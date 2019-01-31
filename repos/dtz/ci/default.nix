{ nixpkgs ? (fetchTarball channel:nixos-unstable),
  src ? (fetchGit ../.)
}:

# Evaluate 'release.nix' but don't abort on unfree, just log and skip

let
  toplevel = import (src + "/release.nix") {
    inherit nixpkgs;
    args.config = {
      allowUnfree = false;
    };
  };
in
  toplevel // {
    pkgs = builtins.removeAttrs toplevel.pkgs [
      "diva"
      "stoke" "stoke-haswell" "stoke-sandybridge"
      "ycomp"
    ];
  }
