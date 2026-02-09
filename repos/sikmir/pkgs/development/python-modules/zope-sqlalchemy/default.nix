{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "zope-sqlalchemy";
  version = "4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.sqlalchemy";
    tag = finalAttrs.version;
    hash = "sha256-E8Z1ljtF66K7XVfIU9pmXVYduzMOGaemNWmN1ysSm1w=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    sqlalchemy
    transaction
    zope-interface
  ];

  pythonImportsCheck = [ "zope.sqlalchemy" ];

  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Integration of SQLAlchemy with transaction management";
    homepage = "https://github.com/zopefoundation/zope.sqlalchemy";
    license = lib.licenses.zpl21;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
