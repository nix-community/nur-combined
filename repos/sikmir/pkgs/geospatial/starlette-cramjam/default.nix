{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "starlette-cramjam";
  version = "0.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "starlette-cramjam";
    rev = version;
    hash = "sha256-4LWn0qePRadyEsoLVSLOPRQ6tP6EG1YnVZzDsZH0+0I=";
  };

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    httpx
    starlette
    cramjam
    typing-extensions
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Cramjam integration for Starlette ASGI framework";
    homepage = "https://github.com/developmentseed/starlette-cramjam";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
