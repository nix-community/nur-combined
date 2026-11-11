{
  lib,
  buildPythonPackage,
  hatchling,
  pg0,
}:

buildPythonPackage (finalAttrs: {
  pname = "pg0-embedded";

  inherit (pg0) version src;
  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/sdk/python";

  build-system = [ hatchling ];

  env.PG0_BINARY_PATH = lib.getExe pg0;

  doCheck = false;

  pythonImportsCheck = [ "pg0" ];

  meta = {
    description = "Python API for pg0, an embedded PostgreSQL with pgvector";
    homepage = "https://github.com/vectorize-io/pg0";
    changelog = "https://github.com/vectorize-io/pg0/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ brudel ];
    platforms = pg0.meta.platforms;
  };
})
