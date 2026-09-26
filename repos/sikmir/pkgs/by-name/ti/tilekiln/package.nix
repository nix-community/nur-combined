{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  pmtiles,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tilekiln";
  version = "0.8.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pnorman";
    repo = "tilekiln";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CnrmWh31bgg7TkPjsLJO7nS27bUV5ninhIGWezMANng=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -i 's/len(os.sched_getaffinity(0))/4/' tilekiln/scripts/{generate,serve}.py
  '';

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  dependencies = with python3Packages; [
    click
    fastapi
    fs
    jinja2
    setuptools_80
    pmtiles
    prometheus-client
    psycopg
    psycopg.optional-dependencies.pool
    pyyaml
    tqdm
    uvicorn
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "A set of command-line utilities to generate and serve Mapbox Vector Tiles (MVTs)";
    homepage = "https://github.com/pnorman/tilekiln";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # https://github.com/pnorman/tilekiln/issues/73
  };
})
