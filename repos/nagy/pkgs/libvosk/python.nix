{ lib, pkgs, cffi, buildPythonPackage, libvosk }:

buildPythonPackage {
  pname = "vosk";
  version = "0.3.32";
  propagatedBuildInputs = [ cffi ];
  src = "${libvosk.src}/../python/";

  VOSK_SOURCE = "${libvosk.src}/../";

  postPatch = ''
    substituteInPlace vosk/__init__.py \
      --replace  "libvosk.so" "${libvosk}/lib/libvosk.so"
  '';

  doCheck = false;
}
