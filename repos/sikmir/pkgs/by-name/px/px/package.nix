{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "px";
  version = "3.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "walles";
    repo = "px";
    tag = version;
    hash = "sha256-cCTaDs/BYmL6Ql3kAzCk169M7JqenXeLhwsG1ErE2DI=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  meta = {
    description = "ps, top and pstree for human beings";
    homepage = "https://github.com/walles/px";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
