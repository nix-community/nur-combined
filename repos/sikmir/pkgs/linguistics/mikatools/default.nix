{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "mikatools";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mikahama";
    repo = "mikatools";
    rev = version;
    hash = "sha256-CfukGTPT0Yv4Q2H+g7XJfNgNchhslaA7/mgupqlOQ+o=";
  };

  propagatedBuildInputs = with python3Packages; [ requests clint cryptography ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Mikatools provides fast and easy methods for common Python coding tasks";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
