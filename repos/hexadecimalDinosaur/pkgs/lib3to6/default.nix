{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  pathlib2,
  astor,
  click,
}:


buildPythonPackage rec {
  pname = "lib3to6";
  version = "202107.1047";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ai2zMLQqBWoPCSB6B0BEXQKURIkMaeIFgu+Zriestxc=";
  };

  doCheck = false;

  dependencies = [
    pathlib2
    astor
    click
  ];

  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];

   meta = {
    description = "Build universally compatible python packages from a substantial subset of Python 3.8";
    homepage = "https://github.com/mbarkhau/lib3to6";
    changelog = "https://github.com/mbarkhau/lib3to6/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
