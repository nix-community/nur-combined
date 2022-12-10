{ lib
, stdenv
, python3Packages
, maintainers
, spython
}:

python3Packages.buildPythonApplication rec {
  pname = "singularity-hpc";
  version = "0.1.17";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-ZZjkvHvePv4+PYo9tsUmGPNHPn/BFoL3T7XwcDpe2hQ=";
  };

  pythonImportsCheck = [
    "shpc"
  ];
  propagatedBuildInputs = [
    python3Packages.setuptools
    python3Packages.pytest
    python3Packages.pytest-runner
    python3Packages.requests
    python3Packages.jinja2
    python3Packages.jsonschema
    python3Packages.ruamel-yaml
    spython
  ];

  # Only support for Python 3
  doCheck = !python3Packages.isPy27;

  meta = with lib; {
    description = "Local filesystem registry for containers (intended for HPC) using Lmod or Environment Modules. Works for users and admins. ";
    homepage = "https://github.com/singularityhub/singularity-hpc";
    license = licenses.mpl20;
    maintainers = [ maintainers.vsoch ];
  };

}
