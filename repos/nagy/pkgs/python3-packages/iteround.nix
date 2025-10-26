{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "iteround";
  version = "1.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cgdeboer";
    repo = "iteround";
    rev = "v${version}";
    hash = "sha256-0lHu01MTf+rdrUYuRDR2IUvQQKcw7NZXBOw+nbEmPMc=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "iteround" ];

  meta = with lib; {
    description = "Rounds iterables (arrays, lists, sets, etc) while maintaining the sum of the initial array";
    homepage = "https://pypi.org/project/iteround/";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
    mainProgram = "iteround";
  };
}
