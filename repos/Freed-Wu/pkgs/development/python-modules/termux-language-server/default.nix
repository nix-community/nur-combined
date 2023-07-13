{ mySources
, python3
, lib
, setuptools-generate
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.termux-language-server) pname version src;
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
    "termux_language_server"
  ];

  meta = with lib; {
    homepage = "https://termux-language-server.readthedocs.io";
    description = "termux build.sh language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
