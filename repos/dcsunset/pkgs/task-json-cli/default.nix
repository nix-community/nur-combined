{ lib, buildNpmPackage, fetchFromGitHub, installShellFiles }:

buildNpmPackage rec {
  pname = "task-json-cli";
  version = "8.3.1";

  src = fetchFromGitHub {
    owner = "task-json";
    repo = "task.json-cli";
    rev = "v${version}";
    hash = "sha256-r4gz7R962jCKdEGKo78GFWd0/LMRwCI+ECdRq0E3yPs=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-RLi3/IEYVMHaZkLwu315Jh7cFJyzWVj1zDeuqTXTcY0=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --zsh completion/_tj
  '';

  meta = with lib; {
    description = "Command-line todo management app based on task.json format";
    homepage = "https://github.com/task-json/task.json-cli";
    license = licenses.agpl3;
  };
}
