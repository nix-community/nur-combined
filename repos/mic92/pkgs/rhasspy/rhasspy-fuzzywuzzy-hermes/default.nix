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
  version = "0.3.2";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-MiL4e/xHTr2ZSG2XDPpxLwJRvHUkIavSn+/4Wdfz43A=";
  };

  propagatedBuildInputs = [
    rhasspy-fuzzywuzzy
    rhasspy-hermes
    rhasspy-nlu
  ];

  postPatch = ''
    sed -i "s/networkx==.*/networkx/" requirements.txt
  '';

  doCheck = false;

  meta = with lib; {
    description = "MQTT service for intent recognition with fuzzywuzzy using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-fuzzywuzzy-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
