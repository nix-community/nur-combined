{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, rhasspy-nlu
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-nlu-hermes";
  version = "0.1.4";

  disabled = pythonOlder "3.7"; # requires python version >=3.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "e02cf5a1642805da2957e7d44ed47621b6cbfbb15e6c4c243a2cd128294aeb0e";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
    rhasspy-nlu
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/rhasspy/rhasspy-nlu-hermes/commit/bbe94156e0b3111e18207e4cf34c75ae3090ab70.patch";
      sha256 = "1g6a1y5qnh7y6kx4pq5vhhw4ln1kzazyy95c8spa786dipnz0svj";
    })
  ];

  meta = with lib; {
    description = "MQTT service for natural language understanding using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-nlu-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
