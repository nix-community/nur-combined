#
# Example of a top-level nixpkgs file that provides
# multiple versions of the overlay and nixpkgs
#
{ overlays ? [], ... }@args :

let
  lib = import "${srcStable}/lib";
  args' = lib.filterAttrs (n: v: n != "overlays") args;

  fetchNixpkgs = rev:
    builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";

  fetchQchem = rev:
    builtins.fetchTarball "https://github.com/markuskowa/NixOS-QChem/archive/${rev}.tar.gz";

  createPkgs = src: overlay: import src ({
    overlays = overlay;
  } // args' );

  composePkgs = src: srcQchem: name:
    { "${name}" = (createPkgs src (overlays ++ [ (import srcQchem) ])).qchem; };

  # pre-subset overlay
  composePkgsOld = src: srcQchem: name:
    { "${name}" = (createPkgs src (overlays ++ [ (import srcQchem) ])); };

  srcStable = src2009;
  srcUnstable = fetchNixpkgs "master";
  src2009 = fetchNixpkgs "nixos-20.09";
  src2003 = fetchNixpkgs "nixos-20.03";

  setUnstable = createPkgs srcUnstable;

in
  createPkgs srcStable overlays //
  composePkgsOld src2003 (fetchQchem "release-20.03") "qchem-2003" //
  composePkgsOld srcStable (fetchQchem "release-20.09") "qchem" //
  composePkgs srcUnstable (fetchQchem "master") "qchem-unstable"
