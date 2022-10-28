{
  callPackage,
  buildPythonPackage,
  fetchPypi,
  lib,
  pythonOlder,
}: let
  plover = callPackage ./plover {};
in
  buildPythonPackage rec {
    pname = "plover_tapey_tape";
    version = "0.0.6";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-nlSQK7lT5b2l1njmD1YZhBl0QWl9TYPRGAl4q2v17fs=";
    };

    doCheck = false;

    disabled = pythonOlder "3.6";
    propagatedBuildInputs = [plover];

    meta = with lib; {
      description = "Paper tape with extra information";
      license = licenses.gpl3;
    };
    passthru.updateScript = [../scripts/update-python-libraries "plover/plover-tapey-tape.nix"];
  }
