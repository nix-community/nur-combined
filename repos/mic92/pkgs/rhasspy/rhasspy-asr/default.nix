{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
}:

buildPythonPackage rec {
  pname = "rhasspy-asr";
  version = "0.1.5";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8624657c8389e8cd0318efce30b80d5e64c3c0ffb75140458eaf037f989a207b";
  };

  meta = with lib; {
    description = "Shared Python classes for speech to text";
    homepage = "https://github.com/rhasspy/rhasspy-asr";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
