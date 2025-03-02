{
  lib,
  fetchFromGitLab,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "agunua";
  version = "1.7.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "bortzmeyer";
    repo = "agunua";
    rev = "release-${version}";
    hash = "sha256-sVZ4HrFH3bL6FHn8B43rsya3vggIuCXdx6rPh+LG7MA=";
  };

  dependencies = with python3Packages; [
    pyopenssl
    pysocks
    netaddr
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

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
