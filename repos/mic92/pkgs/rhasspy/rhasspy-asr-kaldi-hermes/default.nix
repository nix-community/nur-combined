{ stdenv
, buildPythonPackage
, fetchFromGitHub
, rhasspy-hermes
, attrs
, rhasspy-asr-kaldi
, rhasspy-silence
}:

buildPythonPackage rec {
  pname = "rhasspy-asr-kaldi-hermes";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-UwFTovFy5WbgjaqAqi8B+At4qhvPM8HAWy34yJiJWEw=";
  };

  dontConfigure = true;

  propagatedBuildInputs = [
    rhasspy-hermes
    attrs
    rhasspy-asr-kaldi
    rhasspy-silence
  ];

  postPatch = ''
    sed -i 's/networkx==.*/networkx/' requirements.txt
    sed -i 's/paho-mqtt==.*/paho-mqtt/' requirements.txt
  '';

  # misses files
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Hotword detection for Rhasspy using Porcupine";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
