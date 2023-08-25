{ lib, buildNpmPackage, fetchFromGitHub, installShellFiles }:

buildNpmPackage rec {
  pname = "task-json-cli";
  version = "8.2.4";

  src = fetchFromGitHub {
    owner = "task-json";
    repo = "task.json-cli";
    rev = "v${version}";
    hash = "sha256-eae6zIj1nYqYyINvMBqfr5zkL5wPkBEcR2Wzousrwkc=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-iBZqKY1ZlkTKSk1v1goi6C7b4i/XUMFBHoynVsw7OU0=";

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
