{ stdenv
, buildPythonPackage
, fetchurl
, pip
, isPy38
, numpy
}:
let
  pythonVersion = "38";
  version' = "0.10.0";
  alphaNumber = "3";
in
buildPythonPackage rec {
  pname = "deepspeech_tflite";
  version = "${version'}-alpha.${alphaNumber}";
  disabled = !isPy38;
  wheelName = "deepspeech_tflite-${version'}a${alphaNumber}-cp${pythonVersion}-cp${pythonVersion}-manylinux1_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/${wheelName}";
    sha256 = "sha256-zJd16C7kz93coJcOqbIOSbv5fIwdfX7UGnyqumnTc1w=";
  };

  nativeBuildInputs = [ pip ];

  propagatedBuildInputs = [ numpy ];

  unpackPhase = ":";

  format = "other";

  installPhase = ''
    set +x
    cp $src ${wheelName}
    pip install --prefix=$out ${wheelName}
  '';

  meta = with stdenv.lib; {
    description = "Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers.";
    homepage = "https://github.com/mozilla/DeepSpeech";
    license = licenses.mpl20;
  };
}
