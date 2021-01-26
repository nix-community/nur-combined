{ stdenv
, buildPythonPackage
, fetchFromGitHub
, scipy
, rhasspy-silence
, python_speech_features
, setuptools
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-raven";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "rhasspy-wake-raven";
    rev = "0fa941b1c273f7729e8ac0118aac26c158126ced";
    sha256 = "sha256-4Arc5qFQek6XW9PK3FRrGbsOMPvJSWllowId0RkQyCY=";
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

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Raven";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
