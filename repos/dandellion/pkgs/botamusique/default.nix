{ fetchFromGitHub, python3, python3Packages, ffmpeg, opusTools }:

let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    opuslib
    protobuf
    flask
    youtube-dl
    magic
    pillow
    mutagen
    requests
    packaging
  ]);
in

python3Packages.buildPythonApplication rec {
  pname = "botamusique";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "azlux";
    repo = "botamusique";
    rev = "${version}";
    sha256 = "08gb11ldclg22wn3pa808vw742pvx8rv2w0frmllghsvh63w04ma";
  };

  buildInputs = [ ffmpeg opusTools ];


}
