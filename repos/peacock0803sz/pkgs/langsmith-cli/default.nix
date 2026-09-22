{ lib, buildGo126Module, fetchFromGitHub }:
let
  version = "0.2.58";
in
buildGo126Module {
  pname = "langsmith-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langsmith-cli";
    tag = "v${version}";
    hash = "sha256-lLyaxIVYLDVAhk31iLWL5WdvGCwCxK5+X3ZMVpouzmk=";
  };

  vendorHash = "sha256-Zl9bQSeRLxZ6qjKQbtsPw0wxj/HBU+gXtGGgTrwVkww=";

  subPackages = [ "cmd/langsmith" ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=v${version}"
  ];
  doCheck = false;

  meta = {
    description = "A coding agent-first CLI for interacting with LangSmith";
    homepage = "https://github.com/langchain-ai/langsmith-cli";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "langsmith";
  };
}
