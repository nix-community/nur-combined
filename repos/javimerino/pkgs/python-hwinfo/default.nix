{ fetchFromGitHub
, lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "python-hwinfo";
  version = "0.1.7";
  # fetchPypi can't be used because pypi is behind the original
  # package https://github.com/rdobson/python-hwinfo .
  src = fetchFromGitHub {
    owner = "xenserver";
    repo = "python-hwinfo";
    rev = "3a7bc82f8bc47a2f176e41443ced2709882e2fda";
    hash = "sha256-tqsXaNkPotRJkrehxXi1vHQ6aXBuOlbWxIucEMQ0LN0=";
  };
  format = "setuptools";

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  # TODO add testing using tox
  doCheck = false;
  propagatedBuildInputs = with python3Packages; [
    paramiko
    prettytable
  ];

  meta = with lib; {
    description = "Library for inspecting hardware info using standard linux utilities";
    homepage = "https://github.com/xenserver/python-hwinfo";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.lgpl21Only ];
  };
}
