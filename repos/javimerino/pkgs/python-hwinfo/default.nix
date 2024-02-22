{ fetchFromGitHub
, lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "python-hwinfo";
  version = "0.1.7";
  # fetchPypi can't be used because pypi is behind the original
  # package https://github.com/rdobson/python-hwinfo . This in turn
  # can't be used because it does not have python3 support.
  # https://github.com/rdobson/python-hwinfo/pull/25 adds support for
  # python3
  src = fetchFromGitHub {
    owner = "alexhimmel";
    repo = "rob-python-hwinfo";
    rev = "private/tianxia/CP-41972";
    hash = "sha256-uyaKBtM4f86hu7Ep4NxWf06l3ZeoL3oZAjvErinoLbM=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    paramiko
    prettytable
  ];

  meta = with lib; {
    description = "Library for inspecting hardware info using standard linux utilities";
    homepage = "https://github.com/rdobson/python-hwinfo";
    maintainers = with maintainers; [ javimerino ];
    license = [ licenses.lgpl21Only ];
  };
}
