{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "portolan";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "fitnr";
    repo = "portolan";
    rev = "v${version}";
    hash = "sha256-zKloFO7uCLkqgayxC11JRfMpNxIR+UkT/Xabb9AH8To=";
  };

  meta = with lib; {
    description = "Convert between compass points and degrees";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
  };
}
