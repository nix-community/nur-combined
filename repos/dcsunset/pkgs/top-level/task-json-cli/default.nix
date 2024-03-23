{ lib, buildNpmPackage, fetchFromGitHub, installShellFiles }:

buildNpmPackage rec {
  pname = "task-json-cli";
  version = "8.3.2";

  src = fetchFromGitHub {
    owner = "task-json";
    repo = "task.json-cli";
    rev = "v${version}";
    hash = "sha256-XkP8X83VK+fCu19QxGw8z7xcZ5U9O1baQ+bOCZrWgts=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-u2eOkntgVqrcX+Wxy8wz73yG9TI/17UoISlu9BeW8wY=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --zsh completion/_tj
  '';

  meta = with lib; {
    description = "Command-line todo management app based on task.json format";
    homepage = "https://github.com/task-json/task.json-cli";
    license = licenses.agpl3Only;
  };
}
