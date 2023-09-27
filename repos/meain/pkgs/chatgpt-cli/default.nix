{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "chatgpt-cli";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "kardolus";
    repo = "chatgpt-cli";
    rev = "v${version}";
    hash = "sha256-rFtYdD6U4irbJ8Dj/1mfEWs8x8uJasyotFowV/ku3sc=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" "-X main.GitCommit=${src.rev}" "-X main.GitVersion=${version}" ];

  meta = with lib; {
    description = "A versatile command-line interface for interacting with OpenAI's ChatGPT, featuring streaming support, query mode, and conversation history tracking";
    homepage = "https://github.com/kardolus/chatgpt-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ meain ];
  };
}
