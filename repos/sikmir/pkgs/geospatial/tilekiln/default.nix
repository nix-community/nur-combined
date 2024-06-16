{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilekiln";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "pnorman";
    repo = "tilekiln";
    rev = version;
    hash = "sha256-CLeZMfru8hnhotTAmdRc9hG473wD9gc4omD1G1XQkoQ=";
  };

  postPatch =
    ''
      sed -i '/setup_requires=/d' setup.py
    ''
    + lib.optionalString stdenv.isDarwin ''
      sed -i 's/len(os.sched_getaffinity(0))/4/' tilekiln/scripts/__init__.py
    '';

  dependencies = with python3Packages; [
    click
    pyyaml
    fs
    jinja2
    fastapi
    psycopg
    psycopg.optional-dependencies.pool
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
