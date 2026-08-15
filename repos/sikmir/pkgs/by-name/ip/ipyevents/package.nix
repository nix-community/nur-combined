{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  python3Packages,
  nodejs,
  npmHooks,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "ipyevents";
  version = "2.0.4";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "mwcraig";
    repo = "ipyevents";
    tag = finalAttrs.version;
    hash = "sha256-Fbtuw51luxKn9KxsW6dftnAHa2q9rpdaAvFi4mOFk0w=";
  };

  patches = [ ./package-lock.json.patch ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src patches;
    hash = "sha256-CK9p0/G1yS7Msx1ieBEvjod+YsVbM8sLr/R3Gveve6I=";
  };

  build-system = with python3Packages; [
    hatchling
    hatch-jupyter-builder
    jupyterlab
  ];

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  dependencies = with python3Packages; [
    ipywidgets
  ];

  pythonImportsCheck = [ "ipyevents" ];

  meta = {
    description = "A custom widget for returning mouse and keyboard events to Python";
    homepage = "https://github.com/mwcraig/ipyevents";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
