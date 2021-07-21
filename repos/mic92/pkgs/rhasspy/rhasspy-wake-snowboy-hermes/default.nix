{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, paho-mqtt
, snowboy
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-snowboy-hermes";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "72d970350f4ba7a764427724c015d1cbb18e6c67";
    sha256 = "sha256-j2QzIcdF2pQDALzmLjcp4rhgy6yKLhZtb9wjvLKAx+U=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes snowboy
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
