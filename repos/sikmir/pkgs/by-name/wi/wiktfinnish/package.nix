{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication {
  pname = "wiktfinnish";
  version = "2020-02-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = "wiktfinnish";
    rev = "dc0ad5929664d368dc29631927b10e4641b2f0ff";
    hash = "sha256-bUwgHAu/EfAgiNJ/gP9VRHk79S5OH1CXYBGQhkf5Ppw=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  pythonImportsCheck = [ "wiktfinnish" ];

  meta = {
    description = "Finnish morphology (including verb forms, comparatives, cases, possessives, clitics)";
    homepage = "https://github.com/tatuylonen/wiktfinnish";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
