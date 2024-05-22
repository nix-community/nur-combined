{ lib, fetchFromGitHub, fetchPypi, python3Packages }:
let
  wavio = python3Packages.buildPythonPackage rec {
    pname = "wavio";
    version = "0.0.8";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-UcE3aIhdQJW6CCVHhXUC4hI5BdtUf669wAfgOt4Y7V0=";
    };

    dependencies = with python3Packages; [ numpy ];
  };

  auraloss = python3Packages.buildPythonPackage rec {
    pname = "auraloss";
    version = "0.3.0";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Gz+hP9XKA2nUZ16irm07Rxkb08jKbMiy4hf+48YnweA=";
    };

    # Ignoring ~broken~ pyproject file
    patchPhase = "rm pyproject.toml";

    dependencies = with python3Packages; [ numpy torch scipy matplotlib ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "neural-amp-modeler";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "sdatkinson";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-dCAzX0TlIICv4I+/QGDCNDpTLQYeX9kb5bjHOwB2jkk=";
  };

  dependencies = with python3Packages; [ numpy torch wavio transformers sounddevice scipy pytorch-lightning pydantic onnxruntime onnx matplotlib auraloss pytest ];

  meta = with lib; {
    description = "Neural network emulator for guitar amplifiers";
    homepage = "https://github.com/sdatkinson/neural-amp-modeler";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "nam";
  };
}
