{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "starlette-cramjam";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "starlette-cramjam";
    rev = version;
    hash = "sha256-aCZnXsCkzq278aAj4QNz2gSIVWGn1IsL2QG9TAaNWg0=";
  };

  propagatedBuildInputs = with python3Packages; [
    starlette
    cramjam
    typing-extensions
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Cramjam integration for Starlette ASGI framework";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
