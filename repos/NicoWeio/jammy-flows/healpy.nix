{ lib, buildPythonPackage, fetchurl, autoPatchelfHook, stdenv, zlib, numpy, astropy }:

buildPythonPackage rec {
  pname = "healpy";
  version = "1.20.0";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/38/57/2d118c1f3aa0f269a848fb619098367d3efdd25545307dd8ef00499b564d/healpy-1.20.0-cp314-cp314-manylinux_2_28_x86_64.whl";
    hash = "sha256-OlVy2HoKdeBaLbdEbxSgRHmW72gOVfguucZnp5456TU=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib zlib ];
  propagatedBuildInputs = [ numpy astropy ];
  pythonImportsCheck = [ "healpy" ];

  meta = {
    description = "Python package for HEALPix maps";
    homepage = "https://github.com/healpy/healpy";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
