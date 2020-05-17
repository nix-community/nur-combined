{ stdenv, fetchFromGitHub, buildPythonPackage
, aiohttp, construct, pycryptodomex, click }:

buildPythonPackage rec {
  pname = "pyps4_2ndscreen";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "ktnrg45";
    repo = "pyps4-2ndscreen";
    rev = version;
    sha256 = "1zw0qcks82x64ayykk5q8jcfc70izi0dd5zf4wvb054mxj9m411m";
  };

  propagatedBuildInputs = [ aiohttp construct pycryptodomex click ];

  # Tests need network
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Python Library for controlling a Sony PlayStation 4 Console.";
    homepage = "https://github.com/ktnrg45/pyps4-2ndscreen";
    license = licenses.lgpl21;
  };
}
