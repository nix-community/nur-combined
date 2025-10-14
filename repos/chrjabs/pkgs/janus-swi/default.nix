{
  lib,
  python,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  swi-prolog,
}:
python.pkgs.buildPythonPackage rec {
  pname = "janus-swi";
  version = "1.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SWI-Prolog";
    repo = "packages-swipy";
    rev = "26f2df7c045788c68127c7f23e87f75f30c322ff";
    hash = "sha256-6Xqa+JKmAMX1Sm23PzI5gr9L2gkO24YhO/VgPpQCoMc=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  nativeBuildInputs = [
    swi-prolog
  ];

  buildInputs = [
    swi-prolog
  ];

  pythonImportsCheck = [ "janus_swi" ];

  meta = {
    description = "A bi-directional interface between SWI-Prolog and Python";
    homepage = "https://github.com/SWI-Prolog/packages-swipy";
    license = lib.licenses.bsd2;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
  };
}
