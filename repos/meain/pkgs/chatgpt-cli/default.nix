{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "chatgpt-cli";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "kardolus";
    repo = "chatgpt-cli";
    rev = "v${version}";
    hash = "sha256-vyGBfTUBJm+dEHhnEUpDsCWwvrzZcfQdK4uaEUZ2Fmg=";
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
