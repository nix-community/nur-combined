{ lib, buildGo126Module, fetchFromGitHub }:
let
  version = "0.2.59";
in
buildGo126Module {
  pname = "langsmith-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langsmith-cli";
    tag = "v${version}";
    hash = "sha256-6iqqOSU0D93/6RsvUuEPqGj2+xIwFrpaIoipPaNhPvY=";
  };

  vendorHash = "sha256-t3gr1YMJ4N7KfJlFALuFf2eeZ87XvlOv8kKiu2RTqyg=";

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
