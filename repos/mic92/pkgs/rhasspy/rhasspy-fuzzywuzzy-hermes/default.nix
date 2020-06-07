{ lib
, buildPythonPackage
, fetchPypi
, fetchpatch
, pythonOlder
, rhasspy-fuzzywuzzy
, rhasspy-hermes
, rhasspy-nlu
}:

buildPythonPackage rec {
  pname = "rhasspy-fuzzywuzzy-hermes";
  version = "0.1.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "47d44446af4b5039bb86e290bab48472c4286c3eb57584f194834bcdb4d9ff2c";
  };

  propagatedBuildInputs = [
    rhasspy-fuzzywuzzy
    rhasspy-hermes
    rhasspy-nlu
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/rhasspy/rhasspy-fuzzywuzzy-hermes/commit/fa20be4a3ebd17718de3b5b883335dc4613801d1.patch";
      sha256 = "1dcmd0icn7880dhxhlw4swhp99nnk9y9fzcyycpan6r4dk2xb4nl";
    })
  ];

  meta = with lib; {
    description = "MQTT service for intent recognition with fuzzywuzzy using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-fuzzywuzzy-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
