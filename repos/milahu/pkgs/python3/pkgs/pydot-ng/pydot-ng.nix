{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, pkgs
, pyparsing
}:

buildPythonPackage rec {
  pname = "pydot-ng";
  version = "2.0.0";
  src = fetchFromGitHub {
    owner = "pydot";
    repo = "pydot-ng";
    rev = version;
    sha256 = "sha256-5BB9p9dRwMop4CnKb8WXZj0YFzAFX7tgw5hdHmv/lpU=";
  };
  propagatedBuildInputs = [
    pyparsing
    pkgs.graphviz
  ];
  meta = with lib; {
    homepage = "https://github.com/pydot/pydot-ng";
    description = "Python interface to Graphviz's Dot";
    license = licenses.mit;
  };
}
