{
  lib,
  python3Packages,
  runCommand,
  makeWrapper,
  avahi,
}:

let
  pname = "activate-dpt";
  version = "0.1";
  name = "${pname}-${version}";
  pyPkg = python3Packages.buildPythonPackage {
    inherit pname version;
    src = ./.;
    pyproject = true;
    build-system = with python3Packages; [ setuptools ];
    propagatedBuildInputs = with python3Packages; [ pyserial ];
  };
in
runCommand "${name}"
  {
    inherit pname version;

    buildInputs = [ makeWrapper ];
    meta = with lib; {
      description = "Python script to activate Ethernet over USB of Sony DPT-RP1";
      maintainers = with maintainers; [ yinfeng ];
      license = licenses.mit;
    };
  }
  ''
    makeWrapper "${pyPkg}/bin/activate-dpt.py" "$out/bin/activate-dpt" \
      --prefix PATH : "${avahi}/bin"
  ''
