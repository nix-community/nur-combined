{ stdenv
, buildPythonPackage
, fetchurl
, pip
, isPy38
, numpy
, autoPatchelfHook
}:
let
  pythonVersion = "38";
in
buildPythonPackage rec {
  pname = "deepspeeche";
  version = "0.9.3";
  disabled = !isPy38;
  wheelName = "deepspeech-${version}-cp${pythonVersion}-cp${pythonVersion}-manylinux1_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida

  src = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/${wheelName}";
    sha256 = "sha256-R3UlaEfYxLFsYEYlYfl6bazzJRg0acefQr10TAZHngw=";
  };

  buildInputs = [ stdenv.cc.cc ];

  nativeBuildInputs = [ pip autoPatchelfHook ];

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
