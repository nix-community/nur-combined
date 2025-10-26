{ lib, fetchFromGitHub, fetchPypi, python3Packages }:
let
  inherit (python3Packages) setuptools;

  wavio = python3Packages.buildPythonPackage rec {
    pname = "wavio";
    version = "0.0.8";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-UcE3aIhdQJW6CCVHhXUC4hI5BdtUf669wAfgOt4Y7V0=";
    };

    dependencies = with python3Packages; [ numpy ];

    pyproject = true;
    build-system = [ setuptools ];
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

    pyproject = true;
    build-system = [ setuptools ];
  };
in
python3Packages.buildPythonApplication rec {
  pname = "nam-trainer";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "sdatkinson";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VgjSeOB3ayhgzv4pGMOdUYhHKFC23Nr6hIxQ/p9SZLw=";
  };

  dependencies = with python3Packages; [ numpy torch wavio transformers sounddevice scipy pytorch-lightning pydantic onnxruntime onnx matplotlib auraloss pytest ];

  pyproject = true;
  build-system = [ setuptools ];

  meta = with lib; {
    description = "Neural network emulator for guitar amplifiers";
    homepage = "https://github.com/sdatkinson/neural-amp-modeler";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "nam";
  };
}
