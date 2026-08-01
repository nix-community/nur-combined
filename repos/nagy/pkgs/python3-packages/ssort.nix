{
  lib,
  pathspec,
  setuptools,
  fetchPypi,
  buildPythonApplication,
}:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.16.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-HnIiz3/7uwUj2I/hkxo2sLvX9HjSlk/rJb42IcUqmB8=";
  };

  propagatedBuildInputs = [
    setuptools
    pathspec
  ];

  meta = {
    description = "Tool for sorting top level statements in python files";
    homepage = "https://github.com/bwhmather/ssort";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ssort";
  };
}
