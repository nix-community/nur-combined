{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "starlette-cramjam";
  version = "0.3.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "starlette-cramjam";
    rev = version;
    hash = "sha256-InxnMpyYg0m92oJfn7YbHECTQE9WMB9MwpoN3slxK7M=";
  };

  nativeBuildInputs = with python3Packages; [ flit ];

  propagatedBuildInputs = with python3Packages; [
    starlette
    cramjam
    typing-extensions
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Cramjam integration for Starlette ASGI framework";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
