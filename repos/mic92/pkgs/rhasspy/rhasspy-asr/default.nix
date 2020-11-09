{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
}:

buildPythonPackage rec {
  pname = "rhasspy-asr";
  version = "0.2.0";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-kq1J87Z0k6t9GNTf2Ue82OtUSAlB4XBtsJBJVRWTYXc=";
  };

  meta = with lib; {
    description = "Shared Python classes for speech to text";
    homepage = "https://github.com/rhasspy/rhasspy-asr";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
