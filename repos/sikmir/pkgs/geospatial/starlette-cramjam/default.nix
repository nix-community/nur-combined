{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "starlette-cramjam";
  version = "0.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "starlette-cramjam";
    tag = version;
    hash = "sha256-NgEW86+HV1zy9B5tRMF6Jw25Icrl6+CU9eZYInwv5To=";
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
