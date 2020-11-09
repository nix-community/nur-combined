{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
}:

buildPythonPackage rec {
  pname = "rapidfuzz";
  version = "0.12.5";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-dNCasSJLoG/oUXU0U3VAeHpa4CUDhcrXFe7VkulHQVw=";
  };

  meta = with lib; {
    description = "Rapid fuzzy string matching";
    homepage = "https://github.com/maxbachmann/rapidfuzz";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
