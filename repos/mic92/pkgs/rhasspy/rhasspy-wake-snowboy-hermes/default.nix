{ stdenv
, buildPythonPackage
, fetchFromGitHub
, paho-mqtt
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-snowboy-hermes";
  version = "2020-10-10";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "8c39d6f68c0ccdbcfedfc67f183d217cb2006abc";
    sha256 = "sha256-7lLYN8f/ZbnC4Qd73/Az0lokLvqqjCi6LdSWdU7Pex4=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  postPatch = ''
    patchShebangs configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  meta = with stdenv.lib; {
    description = "MQTT service for wake word detection with snowboy using Hermes protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
