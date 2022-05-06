{ pkgs ? import ./nix/pkgs.nix {}}:

let
  inherit (pkgs) lib;
  requirements = (import ./nix/requirements.nix { refpkgs = pkgs; });

in requirements.buildMethod {
  pname = "project";
  version = "0.1.0";
  format = "pyproject";

  src = lib.cleanSource ./.;

  nativeBuildInputs = requirements.nativeBuildInputs;

  propagatedBuildInputs = requirements.base;
}

