{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  lark,
}:

buildPythonPackage rec {
  pname = "bof-text";
  version = "unstable-2025-09-05";

  src = fetchFromGitHub {
    owner = "glitch-in-the-herring";
    repo = "bof-text-editor";
    rev = "7b8147b274a79e2f1038731c3cadc53d56337a2e";
    hash = "sha256-gyuvNTA2qN8W5t4aXfvxF6RgcstWt7QNX662oGgLm9w=";
  };

  pyproject = true;

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    lark
  ];

  pythonImportsCheck = [
    "bof_text_editor"
  ];

  meta = with lib; {
    description = "Command line tool for editing Breath of Fire III and IV text sections";
    longDescription = ''
      Extractor and markup intermediary for editing text sections found in
      Breath of Fire III and IV. Can extract text from .EMI files into a
      markup representation, and patch edited text back into the game files.
    '';
    homepage = "https://github.com/glitch-in-the-herring/bof-text-editor";
    license = licenses.mit;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "bof-text";
  };
}
