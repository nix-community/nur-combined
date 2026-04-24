{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyspartn";
  version = "1.0.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyspartn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MI0s+yJzSSZnNXTtXXtiytQrBvd2sZ7F1m+kUoxd3vs=";
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
