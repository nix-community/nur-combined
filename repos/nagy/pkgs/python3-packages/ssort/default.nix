{
  lib,
  pathspec,
  setuptools,
  fetchPypi,
  buildPythonApplication,
}:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.13.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-p7NedyX6k7xr2Cg563AIPPMb1YVFNXU0KI2Yikr47E0=";
  };

  propagatedBuildInputs = [
    setuptools
    pathspec
  ];

  meta = with lib; {
    description = "Tool for sorting top level statements in python files";
    homepage = "https://github.com/bwhmather/ssort/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
