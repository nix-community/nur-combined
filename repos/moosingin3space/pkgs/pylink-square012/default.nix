{
  lib
, buildPythonPackage
, fetchPypi

, six
, psutil
, future
}:
buildPythonPackage rec {
  version = "0.12.0";
  pname = "pylink-square";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-W9Sixwmwl9ABkey+Go7eRmFzlSddB8kyxTjtvyoFAgc=";
  };

  propagatedBuildInputs = [
    six
    psutil
    future
  ];
}