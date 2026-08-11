{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pysquashfsimage";
  version = "0.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "matteomattei";
    repo = "PySquashfsImage";
    rev = "v${version}";
    hash = "sha256-yQnXqCe/nMx+HGgNThdlnyvdNI++6n3iC3c0YvFl0Jk=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "PySquashfsImage"
  ];

  meta = {
    description = "Python library to read Squashfs image files";
    homepage = "https://github.com/matteomattei/PySquashfsImage";
    license = with lib.licenses; [ gpl3Only lgpl21Only ];
    maintainers = with lib.maintainers; [ ];
  };
}
