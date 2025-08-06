{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  pmtiles,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilekiln";
  version = "0.8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pnorman";
    repo = "tilekiln";
    tag = "v${version}";
    hash = "sha256-TLROZGSY2yqbbSHoUOfqaUz+g9K9gltfH7BmZPUx73k=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
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
    pmtiles
    prometheus_client
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
  };
}
