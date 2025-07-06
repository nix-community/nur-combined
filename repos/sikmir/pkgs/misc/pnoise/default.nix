{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "pnoise";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "plottertools";
    repo = "pnoise";
    tag = version;
    hash = "sha256-JwWzLvgCNSLRs/ToZNFH6fN6VLEsQTmsgxxkugwjA9k=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ numpy ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Vectorized port of Processing noise() function";
    homepage = "https://github.com/plottertools/pnoise";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
