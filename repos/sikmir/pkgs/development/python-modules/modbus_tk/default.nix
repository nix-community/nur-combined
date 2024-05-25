{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "modbus_tk";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "ljean";
    repo = "modbus-tk";
    rev = version;
    hash = "sha256-zikfVMFdlOJvuKVQGEsK03i58X6BGFsGWGrGOJZGC0g=";
  };

  propagatedBuildInputs = with python3Packages; [ pyserial ];

  meta = {
    description = "Implementation of modbus protocol in python";
    inherit (src.meta) homepage;
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
