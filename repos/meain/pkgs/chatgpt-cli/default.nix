{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "chatgpt-cli";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "kardolus";
    repo = "chatgpt-cli";
    rev = "v${version}";
    hash = "sha256-PqZEtmbAhVTRjjSOmTT/BS8LS1FL2F8RZP1WFbMsH64=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A versatile command-line interface for interacting with OpenAI's ChatGPT, featuring streaming support, query mode, and conversation history tracking";
    homepage = "https://github.com/kardolus/chatgpt-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ meain ];
  };
}
