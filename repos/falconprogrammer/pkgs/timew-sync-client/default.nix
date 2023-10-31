{ lib
, buildPythonApplication
, fetchFromGitHub
, setuptools
, wheel
, attrs
, black
, colorama
, iniconfig
, jwcrypto
, pluggy
, py
, pytest
, requests
, six
, callPackage
, ...
}:
let
  python-jwt = callPackage ../python-jwt { };
in
buildPythonApplication rec {
  pname = "timew-sync-client";
  version = "unstable-2023-10-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "timewarrior-synchronize";
    repo = "timew-sync-client";
    rev = "7b048194387eaac3aa3a7834ac8f31d64ad6cbbb";
    hash = "sha256-rE0QBUo5iTwH9ZNo/2o0II95oG4jalx0ZWKn7v66CJ8=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    attrs
    black
    colorama
    iniconfig
    jwcrypto
    pluggy
    py
    pytest
    python-jwt
    requests
    six
  ];

  pythonImportsCheck = [ "timewsync" ];

  meta = with lib; {
    description = "The timewarrior synchronization client";
    homepage = "https://github.com/timewarrior-synchronize/timew-sync-client";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "timew-sync-client";
  };
}
