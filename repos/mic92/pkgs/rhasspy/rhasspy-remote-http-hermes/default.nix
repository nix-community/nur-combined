{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, aiohttp
, rhasspy-hermes
, rhasspy-nlu
, rhasspy-silence
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-remote-http-hermes";
  version = "0.3.1";

  disabled = pythonOlder "3.7"; # requires python version >=3.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-FnbfCsJGQRdCo96lz/l3pORoFiQGYj46XtnVY3SsHyI=";
  };

  propagatedBuildInputs = [
    aiohttp
    rhasspy-hermes
    rhasspy-nlu
    rhasspy-silence
  ];

  meta = with lib; {
    description = "MQTT service to use remote Rhasspy server with the Hermes protocol";
    homepage = "https://github.com/rhasspy/rhasspy-remote-http-hermes";
    license = licenses.mit; # unable to map license to nix license format
    maintainers = [ maintainers.mic92 ];
  };
}
