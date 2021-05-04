{ lib, stdenv, fetchFromGitHub, python, buildPythonPackage, cython, setuptools,
numpy, scipy, mido, pyaudio, pytest, pytestrunner, ffmpeg }:

buildPythonPackage rec {
  pname = "madmom";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "CPJKU";
    repo = pname;
    rev = "v${version}";
    sha256 = "1x0pwxnky4xisyxhjdx2h4bgj426drr3iz8j9qhzcdzzz1mgg4xc";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [ setuptools numpy scipy mido pyaudio ];

  patches = [ ./no-setup-requires-pytestrunner.patch ];

  # Some tests complain about this:
  #   ImportError: cannot import name 'BEATS_LSTM' from 'madmom.models' (unknown location)
  # Strangely, the package exists in the final build.
  doCheck = false;
  checkInputs = [ pytest pytestrunner ffmpeg ];

  meta = with lib; {
    description = "Python audio and music signal processing library.";
    homepage = "https://github.com/CPJKU/madmom";
    license = licenses.mit;
  };
}
