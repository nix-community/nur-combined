{ fetchFromGitHub }:

{
  version = "2018-08-15";
  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "mcsema";
    rev = "22934d3d85a07bfbc557944c5cc74302079373dd";
    sha256 = "036nsh92fms4hfi3bwrkf9ifkry3li67wvpc94d73h492b97000i";
    name = "mcsema-source";
  };
}
