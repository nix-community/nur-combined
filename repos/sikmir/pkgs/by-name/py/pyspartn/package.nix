{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyspartn";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyspartn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tVTjvz7mLKBIW+YERAj95XgL3rvDWXFcURqjIf9Xc/w=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ cryptography ];

  pythonImportsCheck = [ "pyspartn" ];

  meta = {
    description = "SPARTN protocol parser";
    homepage = "https://github.com/semuconsulting/pyspartn";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
