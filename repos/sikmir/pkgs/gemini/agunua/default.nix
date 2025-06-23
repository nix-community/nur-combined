{
  lib,
  fetchFromGitLab,
  python312Packages,
}:

python312Packages.buildPythonApplication rec {
  pname = "agunua";
  version = "1.7.2";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "bortzmeyer";
    repo = "agunua";
    tag = "release-${version}";
    hash = "sha256-a/2906Hyr5rropuwxZQk1vXU0Ilaw1cPZjJlOdoJhsk=";
  };

  dependencies = with python312Packages; [
    pyopenssl
    pysocks
    netaddr
  ];

  nativeCheckInputs = with python312Packages; [ pytestCheckHook ];

  disabledTestPaths = [
    "tests/test_egsam.py"
    "tests/test_full.py"
  ];

  meta = {
    description = "Python library for the development of Gemini clients";
    homepage = "https://framagit.org/bortzmeyer/agunua";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
