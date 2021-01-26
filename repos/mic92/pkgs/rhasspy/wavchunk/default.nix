{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "wavchunk";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-HGpAv/HN/U6Vzo9U3d6aSsswdaG8Hn2phUhZmDtL4nA=";
  };

  # requires files not in pypi
  doCheck = false;

  meta = with lib; {
    description = "Read or write INFO chunks in WAV files";
    homepage = "https://github.com/synesthesiam/wav-chunk";
    license = licenses.mit;
  };
}
