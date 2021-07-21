{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, paho-mqtt
, rhasspy-hermes
, attrs
, pvporcupine
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-porcupine-hermes";

  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FS0/Cxtz0y84xeJHE8m7vHbl3RGLu5kMMlnJWcXthuo=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    attrs
    pvporcupine
  ];

  postPatch = ''
    patchShebangs configure
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  meta = with lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
