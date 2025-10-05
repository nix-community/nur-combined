{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "starlette-cramjam";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "starlette-cramjam";
    tag = version;
    hash = "sha256-D4kYEXL4WTle3HnWwzub/AWwMm9xDIYdAVgpPmkJmns=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    httpx
    starlette
    cramjam
    typing-extensions
  ];

  pythonRelaxDeps = true;

  doCheck = false;
  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Cramjam integration for Starlette ASGI framework";
    homepage = "https://github.com/developmentseed/starlette-cramjam";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
