{ lib
, buildPythonApplication
, pythonOlder
, fetchPypi
, python
  # test inputs
, pytestCheckHook
}:

buildPythonApplication rec {
  pname = "tuna";
  version = "0.5.11";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  # Use Pypi vs GitHub b/c the required JS dependencies require semi-complicated node install
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1H8+OegK+WHI3wFqyX0WQ8PGC160USmdoKtf5BHYhmw=";
  };

  installCheckPhase = ''
    test -e $out/${python.sitePackages}/tuna/web/static/d3.min.js
  '';

  meta = with lib; {
    description = "Python profile viewer";
    homepage = "https://github.com/nschloe/tuna";
    changelog = "https://github.com/nschloe/tuna/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
