{
  lib,
  fetchFromGitHub,
  python3Packages,
  python-cmr,
  pqdm,
  tinynetrc,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "earthaccess";
  version = "0.16.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nsidc";
    repo = "earthaccess";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/DJW0wHXUC/a9xO+c58bw5jWnrK4vlHta7nbFicAgcE=";
  };

  build-system = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  dependencies = with python3Packages; [
    python-cmr
    pqdm
    requests
    s3fs
    fsspec
    tinynetrc
    multimethod
    importlib-resources
    tenacity
    typing-extensions
    numpy
  ];

  pythonImportsCheck = [ "earthaccess" ];

  meta = {
    description = "Client library for NASA Earthdata APIs";
    homepage = "https://github.com/nsidc/earthaccess";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
