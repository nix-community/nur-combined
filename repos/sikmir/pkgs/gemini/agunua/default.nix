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

  propagatedBuildInputs = with python3Packages; [
    pyopenssl
    pysocks
    netaddr
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  disabledTestPaths = [
    "tests/test_egsam.py"
    "tests/test_full.py"
  ];

  meta = with lib; {
    description = "Python library for the development of Gemini clients";
    inherit (src.meta) homepage;
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
  };
}
