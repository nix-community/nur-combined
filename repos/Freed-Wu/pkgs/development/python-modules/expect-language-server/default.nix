{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.expect-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    pygls
    platformdirs
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "expect_language_server"
  ];

  meta = with lib; {
    homepage = "https://expect-language-server.readthedocs.io";
    description = "expect's language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
