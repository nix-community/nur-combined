{ lib, fetchFromGitLab, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "agunua";
  version = "1.5";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "bortzmeyer";
    repo = pname;
    rev = "release-${version}";
    hash = "sha256-DevVruaIYj0jfvBRWT3f1s2HF9Jb5yv//hNd6lmOlb0=";
  };

  propagatedBuildInputs = with python3Packages; [
    pyopenssl
    pysocks
    netaddr
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTestPaths = [
    "tests/test_egsam.py"
    "tests/test_full.py"
    "tests/test_random_projects.py"
    "tests/test_torture.py"
  ];

  meta = with lib; {
    description = "Python library for the development of Gemini clients";
    inherit (src.meta) homepage;
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
  };
}
