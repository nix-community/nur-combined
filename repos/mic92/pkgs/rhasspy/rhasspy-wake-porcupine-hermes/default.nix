{ stdenv, buildPythonPackage, fetchFromGitHub
, paho-mqtt, rhasspy-hermes, attrs }:

buildPythonPackage rec {
  pname = "rhasspy-wake-porcupine-hermes";
  version = "2020-06-05";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "ef7ae6e830f16adb741e913e7efdcb668683d904";
    sha256 = "05ngsdqhqnsj463p3zazxgsqf2v2chqwa678hm4j2j9135rg817s";
  };

  propagatedBuildInputs = [
    rhasspy-hermes attrs
  ];

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
