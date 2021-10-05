let
  sources = import ./sources.nix;
  qchemOvl = import sources.NixOS-QChem;
  nixpkgs = import sources.nixpkgs;
  pkgs = nixpkgs {
    overlays = [ qchemOvl ];
    config = {
      allowUnfree = true;
      qchem-config = {
        allowEnv = false;
        optArch = "skylake";
      };
    };
  };

in pkgs
