{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fastapi,
  aiosqlite,
  async-lru,
  httpx,
  loguru,
  lxml,
  pydantic_1,
  python-dotenv,
  starlette,
  sentry-sdk,
  uvicorn,
  xextract,
  poetry-core,
  pythonRelaxDepsHook,
  makeWrapper,
}:

let
  starlette_047 = starlette.overridePythonAttrs (old: rec {
    version = "0.47.2";
    src = old.src.override {
      tag = version;
      hash = "sha256-FseSZrLWuNaLro2iLMcfiCrbx2Gz8+aEmLaSk/+PgN4=";
    };
  });

  # fastapi and linguee-api depend on different version of pydantic
  # replace dependency pydantic with pydantic_1
  fastapi-customized =
    (fastapi.override {
      pydantic = pydantic_1;
      starlette = starlette_047;
    }).overridePythonAttrs
      (old: rec {
        version = "0.116.1";
        src = old.src.override {
          tag = version;
          hash = "sha256-sd0SnaxuuF3Zaxx7rffn4ttBpRmWQoOtXln/amx9rII=";
        };
        doCheck = false;
        disabledTestPaths = [
          # Don't test docs and examples
          "docs_src"
          "tests/test_tutorial/test_sql_databases"
          "tests/test_tutorial/test_query_param_models"
        ];
      });

in
buildPythonPackage {
  pname = "linguee-api";
  version = "2.6.3";
  pyproject = true;
  doCheck = false;
  src = fetchFromGitHub {
    owner = "imankulov";
    repo = "linguee-api";
    rev = "9844c8247b07a2771b1555f09c8bbc6ea83f08d7";
    hash = "sha256-CSskCYnB+mD+jxXWtAuXhLal9UWWFcEPR2olN7EfEZU=";
  };

  nativeBuildInputs = [
    poetry-core
    pythonRelaxDepsHook
    makeWrapper
  ];

  pythonRelaxDeps = true;

  propagatedBuildInputs = [
    aiosqlite
    async-lru
    fastapi-customized
    httpx
    loguru
    lxml
    pydantic_1
    python-dotenv
    sentry-sdk
    uvicorn
    xextract
  ];

  patches = [
    ./determine-storage-location.patch
  ];

  meta = with lib; {
    description = "Proxy to convert HTML responses from linguee.com to JSON format";
    homepage = "https://github.com/imankulov/linguee-api";
    license = licenses.mit;
    maintainers = [ "Andreas Rid" ];
  };
}
