{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "python-mpv";
  version = "0.5.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "08v8kv5jn741v1r4fi8m7haxxphw74452nc8f4n60hglxxhsxiqh";
  };

  
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jaseg/python-mpv";
    description = "python-mpv is a ctypes-based python interface to the mpv media player. It gives you more or less full control of all features of the player, just as the lua interface does";
    license = licenses.agpl3Only;
  };

}
