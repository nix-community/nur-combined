{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, num2words
, networkx
}:

buildPythonPackage rec {
  pname = "rhasspy-nlu";
  version = "0.1.10";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d9b5eead55b4ae458bbd3c2eb1c7f0c36f59cafcf8d3df39a2ab592a94416028";
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
