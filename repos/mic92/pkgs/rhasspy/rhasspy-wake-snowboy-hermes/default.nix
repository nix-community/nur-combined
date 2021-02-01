{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, paho-mqtt
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-snowboy-hermes";
  version = "2020-12-20";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "ddc92bc50010c2039d710e26485f641229c07f2f";
    sha256 = "sha256-2c4vFaj8kLBkZl0v3+N/UfYYEVUNNOaHrCvoiSgY2tE=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  postPatch = ''
    patchShebangs configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  meta = with lib; {
    description = "MQTT service for wake word detection with snowboy using Hermes protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
