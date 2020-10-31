{ lib
, buildPythonPackage
, fetchFromGitHub
, oead
, xxhash
}:

buildPythonPackage rec {
  pname = "botw-utils";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "NiceneNerd";
    repo = pname;
    rev = "v${version}";
    sha256 = "0ywhz2rdm0f30axkx4qh7d50ndr61v2xvpc8v2lxwbam2ad06yvh";
  };

  propagatedBuildInputs = [
    oead
    xxhash
  ];

  checkPhase = ''
    python test.py
  '';

  meta = with lib; {
    description = "A Python library containing various utilities for BOTW modding";
    homepage = "https://github.com/NiceneNerd/botw-utils";
    license = licenses.unlicense;
    maintainers = with maintainers; [ metadark ];
  };
}
