{
  lib,
  buildPythonPackage,
  fetchPypi,
  aiosqlite,
  anyio,
  iso8601,
  pdm-backend,
  pypika-tortoise,
  pytz,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "tortoise-orm";
  version = "0.25.3";
  pyproject = true;

  src = fetchPypi {
    pname = "tortoise_orm";
    inherit version;
    hash = "sha256-tt7dOIOTYkYo7EYijJPfNhUzzrOSWYb6LR0i3ryDin0=";
  };

  build-system = [ pdm-backend ];

  dependencies = [
    aiosqlite
    anyio
    iso8601
    pypika-tortoise
    pytz
    typing-extensions
  ];

  pythonImportsCheck = [ "tortoise" ];

  meta = {
    description = "Easy async ORM for Python with relations in mind";
    homepage = "https://github.com/tortoise/tortoise-orm";
    license = lib.licenses.asl20;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
  };
}
