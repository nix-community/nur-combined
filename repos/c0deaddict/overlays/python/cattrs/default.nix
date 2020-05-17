{ stdenv, fetchPypi, buildPythonPackage
, pytest }:

buildPythonPackage rec {
  pname = "cattrs";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0yiw8cy8f4c5jvnq1sjml92rlmi8dqf0qh81zpp44z0jmpw5raxp";
  };

  checkInputs = [ pytest ];

  meta = with stdenv.lib; {
    description = "Composable complex class support for attrs.";
    homepage = "https://pypi.org/project/cattrs";
    license = licenses.mit;
  };
}
