{ lib, stdenv, fetchFromGitHub, python, buildPythonPackage, cython, setuptools,
numpy, scipy, mido, pyaudio, pytest, pytestrunner, ffmpeg }:

buildPythonPackage rec {
  pname = "madmom";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "CPJKU";
    repo = pname;
    rev = "v${version}";
    sha256 = "1f9rr9v61j9rdprdiaw2yan080v326s7s093izj6crwxkyc88l24";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [ setuptools numpy scipy mido pyaudio ];

  patches = [ ./no-setup-requires-pytestrunner.patch ];

  # Tests take very long.
  doCheck = false;
  checkInputs = [ pytest pytestrunner ffmpeg ];

  meta = with lib; {
    description = "Python audio and music signal processing library.";
    homepage = "https://github.com/CPJKU/madmom";
    license = licenses.mit;
  };
}
