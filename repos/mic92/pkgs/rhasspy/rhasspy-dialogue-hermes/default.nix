{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-dialogue-hermes";
  version = "0.1.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f6c77104a732cfebe1f6288b7904b8f95156b49e6b55b660a1a00459852fbffc";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  meta = with lib; {
    description = "MQTT service for dialogue management using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-dialogue-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
