{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numpy,
  stempeg,
  pyaml,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "musdb";
  version = "0.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sigsep";
    repo = "sigsep-mus-db";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9BsJ8vFY1HVNOYjRqMCc+zk99sGUIjyHcAw6/91ynjA=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    stempeg
    pyaml
    tqdm
  ];

  pythonImportsCheck = [
    "musdb"
  ];

  meta = {
    description = "Python parser and tools for MUSDB18 Music Separation Dataset";
    homepage = "https://github.com/sigsep/sigsep-mus-db";
    changelog = "https://github.com/sigsep/sigsep-mus-db/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
