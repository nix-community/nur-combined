{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "modbus_tk";
  version = "2022-07-28";

  src = fetchFromGitHub {
    owner = "dhoomakethu";
    repo = "modbus-tk";
    rev = "9fe168ca06164a4887c85a272c616a86871dddd8";
    hash = "sha256-2fHYFQIeYdtpx+j4S7LRwyG9NLPQ4T/0SgYaQDMQsFA=";
  };

  propagatedBuildInputs = with python3Packages; [ pyserial ];

  meta = with lib; {
    description = "Modbus testkit";
    inherit (src.meta) homepage;
    license = licenses.lgpl2;
    maintainers = [ maintainers.sikmir ];
  };
}
