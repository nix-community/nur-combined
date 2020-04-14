{ stdenv, lib, fetchFromGitHub, python3Packages, python3, ffmpeg }:

let
  version = "7.0.12";
in

python3Packages.buildPythonApplication {
  pname = "vcsi";
  inherit version;

  src = fetchFromGitHub {
    owner = "amietn";
    repo = "vcsi";
    rev = "0957a7b54cefe6119432a6e96dc17c46a6af286a";
    sha256 = "0f2iz6idn77qz546xai9q6kn104jbra8ahkc46bpb6a296c11bdm";
  };

  propagatedBuildInputs = with python3Packages; [
    numpy
    pillow
    jinja2
    texttable
    parsedatetime
    nose
  ] ++ [ ffmpeg ];

  meta = with lib; {
    description = "Create video contact sheets";
    homepage = "https://github.com/amietn/vcsi";
    license = licenses.mit;
  };

}

