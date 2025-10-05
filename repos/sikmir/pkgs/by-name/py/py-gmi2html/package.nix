{
  lib,
  fetchFromGitea,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "gmi2html";
  version = "1.0-unstable-2022-02-16";
  pyproject = true;

  src = fetchFromGitea {
    domain = "notabug.org";
    owner = "tinyrabbit";
    repo = "gmi2html";
    rev = "141c3978961ec6cf8530efc810bcd283320c3628";
    hash = "sha256-MFoNOm/BOao5pOntW9Pqn3IjCCjyw6pJL9OXf9RpGIs=";
  };

  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "A library and CLI tool for converting text/gemini to text/html";
    homepage = "https://notabug.org/tinyrabbit/gmi2html";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
