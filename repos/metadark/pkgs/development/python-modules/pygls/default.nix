{ lib
, buildPythonPackage
, isPy3k
, fetchFromGitHub
, mock
, pytest-asyncio
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pygls";
  version = "0.9.1";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uoHqHp56OoMtulnXyO3PwgBviqoSXw2UR0+ahlIp/ew=";
  };

  checkInputs = [ mock pytest-asyncio pytestCheckHook ];

  meta = with lib; {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    license = licenses.asl20;
    maintainers = with maintainers; [ metadark ];
  };
}
