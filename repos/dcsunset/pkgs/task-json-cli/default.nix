{ lib, buildNpmPackage, fetchFromGitHub, installShellFiles }:

buildNpmPackage rec {
  pname = "task-json-cli";
  version = "8.3.0";

  src = fetchFromGitHub {
    owner = "task-json";
    repo = "task.json-cli";
    rev = "v${version}";
    hash = "sha256-lW6aSTT2T753PFXQZab9HPkyIIHJhTAUSii1nX5YLJs=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-c2saQ+dRwubAlk37Jc6RqQXD5ZEVMMjy6VEZrHe3170=";

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
