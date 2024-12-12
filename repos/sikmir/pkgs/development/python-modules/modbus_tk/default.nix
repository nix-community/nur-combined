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
    tag = version;
    hash = "sha256-zikfVMFdlOJvuKVQGEsK03i58X6BGFsGWGrGOJZGC0g=";
  };

  dependencies = with python3Packages; [ pyserial ];

  meta = {
    description = "Implementation of modbus protocol in python";
    homepage = "https://github.com/ljean/modbus-tk";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
