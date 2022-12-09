{ lib
, stdenv
, python3Packages
, maintainers
, fetchurl
}:

python3Packages.buildPythonApplication rec {
  pname = "pipelib";
  version = "0.0.15";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-HzJ//LyJsjnTvzTqgtofTmOvUt9w5MXvGCkxylKMkEs=";
  };

  pythonImportsCheck = [
    "pipelib"
  ];
  propagatedBuildInputs = [
    python3Packages.setuptools
    python3Packages.pytest
    python3Packages.pytest-runner
  ];

  # Only support for Python 3
  doCheck = !python3Packages.isPy27;

  meta = with lib; {
    description = "Pipelib is a library for creating pipelines. You can parse, compare, and order iterables.";
    homepage = "https://github.com/vsoch/pipelib";
    license = licenses.mpl20;
    maintainers = [ maintainers.vsoch ];
  };

}
