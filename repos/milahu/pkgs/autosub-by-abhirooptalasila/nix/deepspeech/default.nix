{ lib
, buildPythonPackage
, fetchPypi
, python
, six
, pandas
, numba
, soundfile
, sox
, llvmlite
, beautifulsoup4
, pyxdg
, librosa
, resampy
, progressbar2
, tensorflow
, ds_ctcdecoder
}:

buildPythonPackage rec {
  pname = "deepspeech";
  version = "0.9.3";
  disabled = python.pythonVersion != "3.9";
  format = "wheel";
  src = fetchPypi rec {
    inherit pname version format;
    sha256 = "4ucpW6SZerhrT7G9enhDGd/NtQjOJmOAY1FTNMEfoFo=";
    dist = python;
    python = "cp39";
    abi = "cp39";
    platform = "manylinux1_x86_64";
  };
  propagatedBuildInputs = ([
    six
    pandas
    numba
    soundfile
    sox
    llvmlite
    beautifulsoup4
    pyxdg
    (librosa.override { resampy = resampy.override { inherit numba; }; })
    progressbar2
    tensorflow
    ds_ctcdecoder
  ]);
  doCheck = false; # TODO
  meta = with lib; {
    homepage = "https://github.com/mozilla/DeepSpeech";
    description = "DeepSpeech CTC decoder";
    license = licenses.mpl20;
  };
}
