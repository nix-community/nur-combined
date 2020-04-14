{ stdenv, lib, fetchFromGitHub, python3Packages, python3, ffmpeg }:

let
  version = "7";
in

python3Packages.buildPythonApplication {
  pname = "vcsi";
  inherit version;

  src = fetchFromGitHub {
    owner = "amietn";
    repo = "vcsi";
    rev = "v${version}";
    sha256 = "1vcinspxic6307cd1miapwyda095j0zyffmdv0whyjz7drh9hkrk";
  };

  propagatedBuildInputs = with python3Packages; [
    numpy
    pillow
    jinja2
    texttable
    parsedatetime
    nose
  ] ++ [ ffmpeg ];

}

