{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "PyOgg";
  version = "0.6.14a1";
  src = fetchPypi rec {
    inherit pname version;
    sha256 = "gpSzSqWckCAMRjDCzEpbhEByCRQejl0GnXpb41jpQmI="; # TODO
  };
  meta = with lib; {
    homepage = "https://github.com/Zuzu-Typ/PyOgg";
    description = "Xiph.org's Ogg Vorbis, Opus and FLAC for Python";
    license = licenses.bsd3;
  };
}
