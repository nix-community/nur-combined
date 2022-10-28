{
  callPackage,
  buildPythonPackage,
  fetchPypi,
  lib,
  pythonOlder,
  ruamel-yaml,
}: let
  plover = callPackage ./plover {};
in
  buildPythonPackage rec {
    pname = "plover_yaml_dictionary";
    version = "0.0.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Etmq1+9ek1Wa5bAjaoOwv7F2l6zXIveRz/WCBuMwI9Y=";
    };

    doCheck = false;

    disabled = pythonOlder "3.6";
    propagatedBuildInputs = [plover ruamel-yaml];

    meta = with lib; {
      description = "YAML dictionary support for Plover.";
      license = licenses.gpl3Plus;
    };
    passthru.updateScript = [../scripts/update-python-libraries "plover/plover-yaml-dictionary.nix"];
  }
