{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, scipy
, rhasspy-silence
, python_speech_features
, setuptools
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-raven";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "rhasspy-wake-raven";
    rev = "9847924ff3ef92b3c497769e870354ddf8d6da1c";
    sha256 = "sha256-SKwuRExdZP5KkWNA2YvKgeSXFQ8ALwlTC2GgF1D5mhk=";
  };

  propagatedBuildInputs = [
    scipy
    rhasspy-silence
    python_speech_features
    setuptools
  ];

  # require files not distributed on pypi
  doCheck = false;
  postPatch = ''
    patchShebangs configure
    sed -i "s/scipy==.*/scipy/" requirements.txt
    sed -i "s/rhasspy-silence.*/rhasspy-silence/" requirements.txt
  '';

  meta = with lib; {
    description = "Hotword detection for Rhasspy using Raven";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
