{ lib, python3Packages, fetchFromGitHub, scooby }:

python3Packages.buildPythonPackage rec {
  pname = "server-thread";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "banesullivan";
    repo = "server-thread";
    rev = version;
    hash = "sha256-EAL/moz3AIPBRLfAVI2zcCstjLsssKqBrxIDvq9CV3g=";
  };

  propagatedBuildInputs = with python3Packages; [ scooby werkzeug ];

  checkInputs = with python3Packages; [ flask requests pytestCheckHook ];

  meta = with lib; {
    description = "Launch a WSGIApplication in a background thread with werkzeug";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
