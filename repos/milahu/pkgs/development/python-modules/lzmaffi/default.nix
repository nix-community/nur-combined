{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  cffi,
  xz,
}:

buildPythonPackage rec {
  pname = "lzmaffi";
  # version = "0.0.3"; # 2013-03-18
  version = "unstable-2025-07-29";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "r3m0t";
    repo = "backports.lzma";
    # rev = "v${version}";
    # https://github.com/r3m0t/backports.lzma/pull/6
    rev = "80c934b1a98380ae38b3c808f76cf4b7cb68d5fc";
    hash = "sha256-ZJB1B0X8CVoEtTJuz0I90rwsUxp83mb0TPcpunH4MlU=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    cffi
    xz # lzma.h
  ];

  pythonImportsCheck = [
    "lzmaffi"
  ];

  meta = {
    description = "Backport of Python 3.3's standard library module lzma for LZMA/XY compressed files";
    homepage = "https://github.com/r3m0t/backports.lzma";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
  };
}
