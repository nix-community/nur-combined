{ lib
, home-assistant
, makeSetupHook
}:

{ pname
, version
, src
# Directory name to install the component under in custom_components
, component-name ? pname
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
  ] ++ (args.checkInputs or []);
} // builtins.removeAttrs args [ "checkInputs" ])
