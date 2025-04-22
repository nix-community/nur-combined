{ lib
, buildPythonPackage
, fetchPypi
, fetchfossil
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "pluginconf";
  version = "2023.10.26";

  src = fetchfossil {
    url = "https://fossil.include-once.org/pluginspec";
    rev = "b9be77c869281e7773bd8d9d6797743c73d3d1b88e9c9dca56e587762f113a4a";
    hash = "sha256-8p2mRC/lsX/7qjQK41AkXmAdS6nFtieUZwfrMMeUNxo=";
  };

  #pyproject = true;

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "pluginconf" ];

  meta = {
    description = "metadata extraction and plugin basename lookup";
    homepage = "https://pypi.org/project/pluginconf/";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
