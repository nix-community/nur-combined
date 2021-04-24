{ lib
, buildPythonPackage
, fetchFromGitHub
, mock
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "vdf";
  version = "3.3";

  src = fetchFromGitHub {
    owner = "ValvePython";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-MZmyvntcYzORqb5sxLdpFmdjJe8MAFX9n8dn+1uHKzU=";
  };

  checkInputs = [ mock pytestCheckHook ];
  pythonImportsCheck = [ "vdf" ];

  meta = with lib; {
    description = "Library for working with Valve's VDF text format";
    homepage = "https://github.com/ValvePython/vdf";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
