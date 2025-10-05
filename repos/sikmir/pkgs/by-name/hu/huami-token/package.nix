{
  lib,
  fetchFromGitea,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "huami-token";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "argrento";
    repo = "huami-token";
    tag = "v${version}";
    hash = "sha256-nQiz1vrZz0sOoZFQaN9ZtzfDY3zn3Gk0jMdqORDDW3w=";
  };

  pythonRelaxDeps = true;

  build-system = with python3Packages; [ flit ];

  dependencies = with python3Packages; [
    requests
    types-requests
  ];

  meta = {
    description = "Script to obtain watch or band bluetooth token from Huami servers";
    homepage = "https://github.com/argrento/huami-token";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "huami_token";
  };
}
