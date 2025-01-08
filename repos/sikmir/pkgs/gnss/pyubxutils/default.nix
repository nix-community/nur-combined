{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyubx2,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyubxutils";
  version = "1.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyubxutils";
    tag = "v${version}";
    hash = "sha256-/DOZdD9tXNV6t1QFS72Y+a41zhp9ReA0I1Lqi0wkRHM=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyserial
    pyubx2
  ];

  pythonImportsCheck = [ "pyubxutils" ];

  meta = {
    description = "Python UBX GNSS device command line utilities";
    homepage = "https://github.com/semuconsulting/pyubxutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
