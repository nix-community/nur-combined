{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  python3Packages,
  nodejs,
  yarnConfigHook,
}:

let
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "jupyter-widgets";
    repo = "ipyleaflet";
    tag = version;
    hash = "sha256-V8HWrCI4TdPHvV4kGjqK60kx1QBo+/kmhtaIe8JIkus=";
  };

  jupyter-leaflet = python3Packages.buildPythonPackage rec {
    pname = "jupyter-leaflet";
    inherit version src;
    pyproject = true;

    __structuredAttrs = true;

    patches = [ ./yarn.lock.patch ];
    sourceRoot = "${src.name}/python/jupyter_leaflet";

    yarnOfflineCache = fetchYarnDeps {
      inherit src patches sourceRoot;
      hash = "sha256-Y9WrJVP9Tra+5eieD5WYwUeu5JIZ1ZGd92vV/gi8aC0=";
    };

    build-system = with python3Packages; [
      hatchling
      hatch-jupyter-builder
      hatch-nodejs-version
      jupyterlab
    ];

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
    ];

    # Build JS assets ourselves; hatch-jupyter-builder would run `jlpm install` online
    env.SKIP_JUPYTER_BUILDER = true;

    preBuild = ''
      yarn --offline run build
    '';

    meta = {
      description = "ipyleaflet extensions for JupyterLab and Jupyter Notebook";
      homepage = "https://github.com/jupyter-widgets/ipyleaflet";
      license = lib.licenses.bsd3;
      maintainers = [ lib.maintainers.sikmir ];
    };
  };
in
python3Packages.buildPythonPackage {
  pname = "ipyleaflet";
  inherit version src;
  pyproject = true;

  __structuredAttrs = true;

  sourceRoot = "${src.name}/python/ipyleaflet";

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    ipywidgets
    traittypes
    xyzservices
    branca
    jupyter-leaflet
  ];

  pythonImportsCheck = [ "ipyleaflet" ];

  meta = {
    description = "A Jupyter - Leaflet.js bridge";
    homepage = "https://github.com/jupyter-widgets/ipyleaflet";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
