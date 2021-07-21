{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, rhasspy-wake-raven
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-raven-hermes";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "41ff418e10dcda3ed827b8a863a35b46ebda0062";
    sha256 = "sha256-sry3k+JRQWNot4JhWPwgrkUGTyq3VNFMY77YAtc/Z3o=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-wake-raven
  ];

  postPatch = ''
    patchShebangs configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
    sed -i "s/rhasspy-wake-raven.*/rhasspy-wake-raven/" requirements.txt
  '';

  meta = with lib; {
    description = "Hotword detection for Rhasspy using Raven";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
