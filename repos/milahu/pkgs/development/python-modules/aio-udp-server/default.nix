{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  distutils,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-udp-server";
  version = "0.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bashkirtsevich-llc";
    repo = "aioudp";
    rev = "0f026566e45f58df5d511916720badfd82d38c80";
    hash = "sha256-wjsB1r6L1/3h75dnDRayNwxGPzoo1oVr63aghfOb3cg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail \
        ' python_requires=">=3.6.*"' \
        ' python_requires=">=3.6"'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    distutils
  ];

  pythonImportsCheck = [
    "aioudp"
  ];

  meta = {
    description = "Asyncio UDP server";
    homepage = "https://github.com/bashkirtsevich-llc/aioudp";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
