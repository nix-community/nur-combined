{ lib, cffi, buildPythonPackage, libvosk }:

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
  meta = with lib; {
    description =
      "Offline speech recognition API for Android, iOS, Raspberry Pi and servers with Python, Java, C# and Node";
    homepage = "https://github.com/alphacep/vosk-api";
    license = with licenses; [ asl20 ];
  };
}
