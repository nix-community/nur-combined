{ stdenv, buildPythonPackage, fetchPypi
, scipy, rhasspy-silence, python_speech_features
}:

buildPythonPackage rec {
  pname = "rhasspy-wake-raven";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-e8vwFDhOXlQh9QC782Ov+oi0JXzobuQpFRTVoGo67hw=";
  };

  propagatedBuildInputs = [
    scipy
    rhasspy-silence
    python_speech_features
  ];

  # require files not distributed on pypi
  doCheck = false;
  postPatch = ''
    patchShebangs configure
    sed -i "s/scipy==.*/scipy/" requirements.txt
  '';

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Raven";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
