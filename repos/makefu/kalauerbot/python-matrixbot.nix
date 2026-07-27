{ lib
, buildPythonPackage
, fetchPypi
, markdown
, matrix-client
}:

buildPythonPackage rec {
  pname = "python-matrixbot";
  version = "0.0.7";
  CI_COMMIT_TAG = version;

  #src = ./python-matrixbot;
  src = fetchPypi {
    inherit pname version;
    sha256 = "9412981b14ff3ab7ffbb1bfc1691758113ab8d71f731b3093d8808c286b69c71";
  };
  patches = [ ./matrixbot.patch ];

  propagatedBuildInputs = [
    markdown
    matrix-client
  ];

  meta = with lib; {
    description = "A basic bot for Matrix";
    homepage = https://gitlab.com/gibberfish/python-matrixbot;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
