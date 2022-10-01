{ lib
, stdenv
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, oead
, xxhash
}:

buildPythonPackage rec {
  pname = "botw-utils";
  version = "0.2.3";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "NiceneNerd";
    repo = "botw-utils";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-cHsDmhJVLd6p2Ijd3cUOJjcLSjsQkz67AsOB2rL4kHs=";
  };

  propagatedBuildInputs = [
    oead
    xxhash
  ];

  checkPhase = ''
    runHook preCheck
    python test.py
    runHook postCheck
  '';

  pythonImportsCheck = [ "botw" ];

  meta = with lib; {
    description = "A Python library containing various utilities for BOTW modding";
    homepage = "https://github.com/NiceneNerd/botw-utils";
    license = licenses.unlicense;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = stdenv.isDarwin; # oead cmake --build fails with exit code 2 on darwin
  };
}
