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
  version = "0.1.2";

  disabled = pythonOlder "3.7"; # requires python version >=3.7

  src = fetchPypi {
    inherit pname version;
    sha256 = "63ca297f3a663dd894c4e9beb3c0ff9b6449efff4f441730044e2dfaabf1892a";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/rhasspy/rhasspy-remote-http-hermes/commit/7054ff1986bef56f21423d0d10463f1a185aa87e.patch";
      sha256 = "1rqgyrzmwrg373fsldwy16mvv7drhjmisq2351wlcdvi7anr3m3d";
    })
  ];

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
