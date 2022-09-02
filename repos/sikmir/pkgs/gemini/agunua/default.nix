{ lib, fetchFromGitLab, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "agunua";
  version = "2021-11-28";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "bortzmeyer";
    repo = "agunua";
    #rev = "release-${version}";
    rev = "d9700a4781afc283f279e1ec93dbb984bfe95079";
    hash = "sha256-FVTD8QYfSaVOI8qbxQbZ2w+dktg1tpp6eb4IltEpltU=";
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
  ];

  meta = with lib; {
    description = "Python library for the development of Gemini clients";
    inherit (src.meta) homepage;
    license = licenses.gpl2Only;
    maintainers = [ maintainers.sikmir ];
  };
}
