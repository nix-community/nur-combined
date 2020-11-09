{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, rhasspy-hermes
}:

buildPythonPackage rec {
  pname = "rhasspy-speakers-cli-hermes";
  version = "0.2.0";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-QqiMvpWxC9h38AhzC2mi3exVfXtDKODt+nBALXUsJgg=";
  };

  propagatedBuildInputs = [
    rhasspy-hermes
  ];

  meta = with lib; {
    description = "MQTT service for Rhasspy audio output with external program using the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-speakers-cli-hermes";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
