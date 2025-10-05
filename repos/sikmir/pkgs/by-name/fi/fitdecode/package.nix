{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "fitdecode";
  version = "0.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "polyvertex";
    repo = "fitdecode";
    tag = "v${version}";
    hash = "sha256-pW1PgJGqFL2reOYYfpGnQ4WoYFKGMNY8iQJzyHYOly8=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  meta = {
    description = "FIT file parser and decoder";
    homepage = "https://github.com/polyvertex/fitdecode";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
