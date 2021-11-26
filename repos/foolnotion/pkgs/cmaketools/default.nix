{ lib, buildPythonPackage, fetchFromGitHub, fetchPypi, python, cmake, }:
buildPythonPackage rec {
  pname = "cmaketools";
  version = "0.1.6";
  format = "wheel";

  src = fetchPypi {
    inherit version format;
    pname = "cmaketools";
    dist = "py3";
    python = "py3";
    sha256 = "sha256-LZcnnKbxHce8lzZimcFspYsIdow+i0RwNOtInWle18U=";
  };

  nativeBuildInputs = [ python cmake ];

  doCheck = false;
  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "Setuptools extensions for CMake: Seamless integration of Cmake build system to setuptools.";
    homepage = "https://github.com/python-cmaketools/python-cmaketools";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
