{ lib
, home-assistant
, makeSetupHook
}:

{ pname
, version
, src
, ... } @ args:

with home-assistant.python.pkgs; let
  haManifestRequirementsCheckHook = import ./manifest-requirements-check-hook.nix {
    inherit makeSetupHook;
    inherit (home-assistant) python;
  };
in buildPythonPackage (rec {
  inherit pname version src;

  checkInputs = [
    haManifestRequirementsCheckHook
    setuptools
  ] ++ (args.checkInputs or []);
} // builtins.removeAttrs args [ "checkInputs" ])
