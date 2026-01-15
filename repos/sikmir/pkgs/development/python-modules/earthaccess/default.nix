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
  version = "0.11.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nsidc";
    repo = "earthaccess";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N4pRODkCPUNW3EPTLgtSscHJv4B/YN37VNOhzCC33+M=";
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
