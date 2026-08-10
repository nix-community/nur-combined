{
  lib,
  buildPythonPackage,
  fetchPypi,
  pdm-backend,
}:

buildPythonPackage rec {
  pname = "pypika-tortoise";
  version = "0.6.5";
  pyproject = true;

  src = fetchPypi {
    pname = "pypika_tortoise";
    inherit version;
    hash = "sha256-ZNlsm4hFD2NgrSKnBjkztqkJYacxfwSytjyY/V1wVQY=";
  };

  build-system = [ pdm-backend ];

  pythonImportsCheck = [ "pypika_tortoise" ];

  meta = {
    description = "SQL query builder fork streamlined for tortoise-orm";
    homepage = "https://github.com/tortoise/pypika-tortoise";
    license = lib.licenses.asl20;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
  };
}
