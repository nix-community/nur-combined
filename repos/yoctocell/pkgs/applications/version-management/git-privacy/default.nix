{ lib, buildPythonApplication, fetchPypi, pynacl, GitPython, git-filter-repo }:

buildPythonApplication rec {
  pname = "gitprivacy";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1djrhyxssv44cyakjx1cvy3agif1b1jzd0kgf4wh3dgsbwa4x3nn";
  };

  propagatedBuildInputs = [
    git-filter-repo
    GitPython
    pynacl
  ];

  doCheck = false;

  meta = with lib; {
    homepage = https://github.com/EMPRI-DEVOPS/git-privacy;
    description = "Keep your coding hours private";
    license = licenses.bsd2;
    # maintainers = with maintainers; [ yoctocell ];
  };
}
