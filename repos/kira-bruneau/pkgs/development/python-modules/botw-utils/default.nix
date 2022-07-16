{ lib
, buildPythonPackage
, fetchFromGitHub
, oead
, xxhash
, isPy3k
}:

buildPythonPackage rec {
  pname = "botw-utils";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "NiceneNerd";
    repo = pname;
    rev = "v${version}";
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
    badPlatforms = platforms.darwin; # oead cmake --build fails with exit code 2 on darwin
    broken = !isPy3k;
  };
}
