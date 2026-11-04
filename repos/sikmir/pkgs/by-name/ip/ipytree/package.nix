{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  python3Packages,
  nodejs,
  yarnConfigHook,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "ipytree";
  version = "0.2.2-unstable-2022-11-23";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "martinRenou";
    repo = "ipytree";
    rev = "9bcd5090b8d8a3fd168562d941b107679d78e0f3";
    hash = "sha256-FxPbXPt1h5Q+YDQKa9ckAjG6EqK+DY4d2Ub8DHzLMQw=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/js/yarn.lock";
    hash = "sha256-Ffn+uhbXwHmPZ+VkCUACDNtulB4GRJvGrt6DdvW60cc=";
  };

  build-system = with python3Packages; [
    setuptools
    jupyter-packaging
    jupyterlab
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"jupyter_packaging~=0.7.0"' '"jupyter_packaging"' \
      --replace-fail '"jupyterlab==3.*"' '"jupyterlab"'
  '';

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
  ];

  # yarn.lock lives in js/, run the hook there manually
  dontYarnInstallDeps = true;

  # Build JS assets ourselves; jupyter-packaging skips its online build when targets exist
  preBuild = ''
    pushd js
    yarnConfigHook
    yarn --offline run build
    popd
  '';

  dependencies = with python3Packages; [ ipywidgets ];

  pythonImportsCheck = [ "ipytree" ];

  meta = {
    description = "A Tree Widget using Jupyter-widgets protocol and jsTree";
    homepage = "https://github.com/martinRenou/ipytree";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
