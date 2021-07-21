{ lib
, buildPythonPackage
, fetchurl
, pip
, isPy39
, numpy
, autoPatchelfHook
, makeWrapper
, sox
, stdenv
}:
let
  pythonVersion = "39";
in
buildPythonPackage rec {
  pname = "deepspeech_tflite";
  version = "0.10.0-alpha.3";
  disabled = !isPy39;
  wheelVersion = builtins.replaceStrings ["-alpha."] ["a"] version;
  wheelName = "deepspeech_tflite-${wheelVersion}-cp${pythonVersion}-cp${pythonVersion}-manylinux1_x86_64.whl";

  src = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/${wheelName}";
    sha256 = "sha256-xyB4viocVyavx6WYaGZ12+3ThoKE5p/Dj57wUnTfai8=";
  };

  buildInputs = [ stdenv.cc.cc ];

  nativeBuildInputs = [ pip autoPatchelfHook makeWrapper ];

  propagatedBuildInputs = [ numpy ];

  makeWrapperArgs = [ "--prefix PATH : ${sox}/bin" ];

  unpackPhase = ":";

  format = "other";

  installPhase = ''
    cp $src ${wheelName}
    pip install --prefix=$out ${wheelName}
  '';

  meta = with lib; {
    description = "Speech-to-text engine which can run in real time on devices ranging from a Raspberry Pi 4 to high power GPU servers.";
    homepage = "https://github.com/mozilla/DeepSpeech";
    license = licenses.mpl20;
  };
}
