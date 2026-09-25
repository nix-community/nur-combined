{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:

python3Packages.buildPythonApplication {
  pname = "dotrun";
  version = "0-unstable-2025-06-16";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "canonical";
    repo = "dotrun";
    rev = "9fe8c408d6c27f0ab4645b9ec1787c8311a23884";
    hash = "sha256-5XJFHiwwEPojnWGJybeUnP2PrwLq/BLnZQHgWE8rmvM=";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    python3Packages.cachecontrol
    python3Packages.cleo
    python3Packages.docker
    python3Packages.dockerpty
    python3Packages.dulwich
    python3Packages.fastjsonschema
    python3Packages.findpython
    python3Packages.httpx
    python3Packages.keyring
    python3Packages.pbs-installer
    python3Packages.pkginfo
    python3Packages.platformdirs
    python3Packages.python-dotenv
    python3Packages.python-slugify
    python3Packages.requests-toolbelt
    python3Packages.shellingham
    python3Packages.tomlkit
    python3Packages.trove-classifiers
    python3Packages.virtualenv
    python3Packages.zstandard
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "poetry.masonry.api" "poetry.core.masonry.api" \
      --replace-fail "poetry>=0.12" "poetry-core==${python3Packages.poetry-core.version}"
  '';

  pythonRelaxDeps = [
    "docker"
    "python-dotenv"
  ];

  pythonImportsCheck = [
    "dotrun"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=main" ]; };

  meta = {
    description = "A tool for developing Node.js and Python projects";
    homepage = "https://github.com/canonical/dotrun";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "dotrun";
  };
}
