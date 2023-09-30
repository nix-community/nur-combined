{ lib
, buildPythonApplication
, fetchFromGitHub
, setuptools
, html5lib
, validators
, markdown
, pypdf3
, wheel
}:

buildPythonApplication rec {
  pname = "pystitcher";
  version = "1.0.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "captn3m0";
    repo = "pystitcher";
    rev = "v${version}";
    hash = "sha256-JI0gQh05zrrJSUnlDt0e3mG/VoFrzJzvL7JJzSD+2Q8=";
  };

  propagatedBuildInputs =
    [ setuptools html5lib validators markdown pypdf3 wheel ];

  pythonImportsCheck = [ "pystitcher" ];

  meta = with lib; {
    description =
      "Pystitcher stitches your PDF files together, generating nice customizable bookmarks for you using a declarative markdown file as input";
    homepage = "https://github.com/captn3m0/pystitcher";
    changelog =
      "https://github.com/captn3m0/pystitcher/blob/${src.rev}/CHANGELOG.rst";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
  };
}
