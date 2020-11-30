{ stdenv
, buildPythonPackage
, fetchFromGitHub
, paho-mqtt
, rhasspy-hermes
, attrs
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-porcupine-hermes";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "v${version}";
    sha256 = "027l7lwixb8jw67249p1rzh6v825kksinpnwyvl34cnky0vqmq8v";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    attrs
  ];

  postPatch = ''
    patchShebangs configure
  '';

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
