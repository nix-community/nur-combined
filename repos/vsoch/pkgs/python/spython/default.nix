{ lib
, stdenv
, python3Packages
, maintainers
, fetchurl
}:

python3Packages.buildPythonApplication rec {
  pname = "spython";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/singularityhub/singularity-cli/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-XK97ggaC41R2TEN9Df2yD2lqcLvFi1JU9X6b5jyZt2A=";
  };

  pythonImportsCheck = [
    "spython"
    "spython.main"
  ];
  propagatedBuildInputs = [
    python3Packages.setuptools
    python3Packages.pytest
    python3Packages.pytest-runner
  ];

  # Only support for Python 3
  doCheck = !python3Packages.isPy27;

  meta = with lib; {
    description = "Singularity Python (spython) is the Python API for working with Singularity containers. ";
    homepage = "https://github.com/singularityhub/singularity-cli";
    license = licenses.mpl20;
    maintainers = [ maintainers.vsoch ];
  };

}
