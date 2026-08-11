{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "faust-cchardet";
  version = "2.1.18";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-03TuytI8aDg+VJyD6QsWeIveawNU/V7OQCCwRt9afH4=";
  };

  nativeBuildInputs = [
    python3.pkgs.cython
    python3.pkgs.pkgconfig
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "cchardet" ];

  meta = with lib; {
    description = "cChardet is high speed universal character encoding detector";
    homepage = "https://pypi.org/project/faust-cchardet/";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
