{ lib, python38Packages, fetchFromGitHub }:

python38Packages.buildPythonPackage rec {
  pname = "traffic";
  version = "0.5.1";
  format = "pyproject";
 
  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-K2FndFfwwaaj2tTNF/xP2RopcFOcb3w5IU2TQjX1H2Q=";
  };

  # nativeBuildInputs = [ python38Packages.psutil ];
  propagatedBuildInputs = [ python38Packages.psutil ];

  meta = with lib; {
    description = "View network up/down speeds and usage";
    homepage = "https://github.com/meain/${pname}";
    license = licenses.mit;
  };
}
