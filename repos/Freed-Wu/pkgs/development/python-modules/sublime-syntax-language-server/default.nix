{ mySources
, python3
, lib
, setuptools-generate
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.sublime-syntax-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    pygls
    platformdirs
    beautifulsoup4
  ];
  nativeBuildInputs = [
    setuptools-generate
  ];
  pythonImportsCheck = [
    "sublime_syntax_language_server"
  ];

  meta = with lib; {
    homepage = "https://sublime-syntax-language-server.readthedocs.io";
    description = "sublime-syntax language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
