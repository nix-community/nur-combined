{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, oead
, pyyaml
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "byml";
  version = "2.4.2";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = "${pname}-v2";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-j2iixPkZJNXG+2Kag84yMXZeYSX8C4w065BeR8zgqSY=";
  };

  patches = [
    ./relax-requirements.patch
  ];

  propagatedBuildInputs = [
    oead
    pyyaml
    sortedcontainers
  ];

  checkPhase = ''
    runHook preCheck
    PATH=$out/bin:$PATH python test.py
    runHook postCheck
  '';

  pythonImportsCheck = [ "byml" ];

  meta = with lib; {
    description = "Nintendo BYML or BYAML parser, writer and converter";
    homepage = "https://github.com/zeldamods/byml-v2";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    badPlatforms = platforms.darwin; # oead cmake --build fails with exit code 2 on darwin
  };
}
