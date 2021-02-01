{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-asr
, rhasspy-nlu
, deepspeech
}:

buildPythonPackage rec {
  pname = "rhasspy-asr-deepspeech";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "aace6a8c80ab26ed786619e91ebcc51b81e2dc0e";
    sha256 = "sha256-tYLWiERRHItzGpqno3Yp8YWkR//uazPd6SYSfNu2Va0=";

  };

  dontConfigure = true;

  propagatedBuildInputs = [
    rhasspy-asr
    rhasspy-nlu
    deepspeech
  ];

  postPatch = ''
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  # misses files
  doCheck = false;

  meta = with lib; {
    description = "Rhasspy wrapper for Deepspeech ASR";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
