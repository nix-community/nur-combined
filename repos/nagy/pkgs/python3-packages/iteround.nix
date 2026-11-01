{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "iteround";
  version = "1.0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cgdeboer";
    repo = "iteround";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0lHu01MTf+rdrUYuRDR2IUvQQKcw7NZXBOw+nbEmPMc=";
  };

  # The v1.0.4 tag still declares `version="1.0.3"` in setup.py.
  postPatch = ''
    substituteInPlace setup.py --replace-fail 'version="1.0.3"' 'version="${finalAttrs.version}"'
  '';

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
})
