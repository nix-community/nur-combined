{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pretty-midi";
  version = "0.2.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "craffel";
    repo = "pretty-midi";
    tag = finalAttrs.version;
    hash = "sha256-hkhthjTLWVVMHEhWi63rh6hAOZZ6fVMwbBhYvC9xXc8=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    numpy
    mido
    six
    importlib-resources
  ];

  pythonImportsCheck = [
    "pretty_midi"
  ];

  meta = {
    description = "Utility functions for handling MIDI data in a nice/intuitive way";
    homepage = "https://github.com/craffel/pretty-midi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pretty-midi";
  };
})
