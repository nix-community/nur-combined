{ lib, python3, fetchFromGitHub }:

python3.pkgs.buildPythonApplication rec {
  pname = "greazeweazel";
  version = "1.22";
  format = "pyproject";

  PBR_VERSION = version;

  src = fetchFromGitHub {
    owner = "keirf";
    repo = "greaseweazle";
    tag = "v${version}";
    hash = "sha256-Ki4OvtcFn5DH87OCWY7xN9fRhGxlzS9QIuQCJxPWJco=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    bitarray
    crcmod
    pyserial
    requests
    wheel
  ];
}
