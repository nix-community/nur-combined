{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "chatgpt-cli";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "kardolus";
    repo = "chatgpt-cli";
    rev = "v${version}";
    hash = "sha256-h0C7Vd3Cju/9JrMXEbjNooyub1mA4qa7d+03GD4qzvQ=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" "-X main.GitCommit=${src.rev}" "-X main.GitVersion=${version}" ];

  checkPhase = false; # tests need network

  meta = with lib; {
    description = "A versatile command-line interface for interacting with OpenAI's ChatGPT, featuring streaming support, query mode, and conversation history tracking";
    homepage = "https://github.com/kardolus/chatgpt-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ meain ];
  };
}
