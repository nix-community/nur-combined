{ lib
, home-assistant
, makeSetupHook
}:

{ pname
, version
, src
# Directory name to install the component under in custom_components
, component-name ? pname
, ... } @ attrs:

with home-assistant.python.pkgs; let
  haManifestRequirementsCheckHook = import ./manifest-requirements-check-hook.nix {
    inherit makeSetupHook;
    inherit (home-assistant) python;
  };
in buildPythonPackage rec {
  inherit pname version src;
  format = "other";

  propagatedBuildInputs = attrs.propagatedBuildInputs or [];

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/${component-name} $out/custom_components/
  '';

  doCheck = true;

  checkInputs = [
    haManifestRequirementsCheckHook
  ] ++ (attrs.checkInputs or []);
}
