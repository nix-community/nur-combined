{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gitignore-template";
  version = "1.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "JonBoyleCoding";
    repo = "gitignore-template";
    rev = version;
    hash = "sha256-HeJXgRxXkzo+HxS5l7MSyHlURZolQqOfkb3kEmGObqU=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
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
