{ lib
, pdm-pep517
, python3
, fetchFromGitHub
, buildPythonApplication
, pygithub
, levenshtein
, requests
, typer
}:

buildPythonApplication rec {
  pname = "gitignore-template";
  version = "1.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "JonBoyleCoding";
    repo = "gitignore-template";
    rev = version;
    hash = "sha256-A8SczWSLwHOZbfxMGyv0Cr53eVfoWmQ8KgjaBE9t3Ds=";
  };

  nativeBuildInputs = [
    pdm-pep517
  ];

  propagatedBuildInputs = [
    pygithub
    levenshtein
    requests
    typer
  ];

  pythonImportsCheck = [ "gitignore_template" ];

  meta = with lib; {
    description = "Download the gitignore template from github.com/github/gitignore into the current directory";
    homepage = "https://github.com/JonBoyleCoding/gitignore-template";
    changelog = "https://github.com/JonBoyleCoding/gitignore-template/blob/${src.rev}/CHANGES.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "gitignore-template";
  };
}
