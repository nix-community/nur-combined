{ pkgs ? import ./nix/pkgs.nix {}}:

let
  inherit (pkgs) poetry mkShell;
  requirements = (import ./nix/requirements.nix { refpkgs = pkgs; });

  pythonEnvironment = requirements.python.buildEnv.override {
    extraLibs = requirements.base ++ requirements.tests ++ requirements.dev;
  };
  extraPkgs = [ poetry ];

in
mkShell {
  buildInputs = [ pythonEnvironment ] ++ extraPkgs;
}
