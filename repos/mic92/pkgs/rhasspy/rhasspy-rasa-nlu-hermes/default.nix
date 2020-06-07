{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
, rhasspy-nlu
, fetchpatch
, aiohttp
}:

buildPythonPackage rec {
  pname = "rhasspy-rasa-nlu-hermes";
  version = "0.1.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "71a4331221f566390b709cffc59d7ac474b35a05180bf7a5b94cdad5d689772f";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/rhasspy/rhasspy-rasa-nlu-hermes/commit/738d43950d8df6d4ca15a16f579b3ec1d7ba82de.patch";
      sha256 = "01vkkim6d7vhv2a0cvyf2d51rz9akprxwxp635jsz4j8vbnxczwq";
    })
  ];

  propagatedBuildInputs = [
    aiohttp
    rhasspy-hermes
    rhasspy-nlu
  ];

  meta = with lib; {
    description = "MQTT service for natural language understanding in Rhasspy using Rasa NLU with the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-rasa-nlu-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
