{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, num2words
, networkx
}:

buildPythonPackage rec {
  pname = "rhasspy-nlu";
  version = "0.3.3";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-VjS/jnSGzCAfcPAVWsDa7JD5Kl1dbQLtTEnOrlAXdpg=";
  };

  propagatedBuildInputs = [
    num2words
    networkx
  ];

  # misses files from the repo
  doCheck = false;

  meta = with lib; {
    description = "Natural language understanding library for Rhasspy";
    homepage = "https://github.com/rhasspy/rhasspy-nlu";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
