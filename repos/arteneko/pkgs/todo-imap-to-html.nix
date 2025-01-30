{ pkgs, lib, fetchFromSourcehut, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "todo-imap-to-html";
  version = "1.1.0";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "todo-imap-to-html";
    rev = "v${version}";
    hash = "sha256-WUi3TZnxgn1P5T2jrnX8cD/ZrT/zOw/Ffz8bQNvRN68=";
  };

  cargoHash = "sha256-OFvTccoIv9iRHMbShx300ffhnT3RyDpFQtmRzglVApM=";

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ openssl ];

  meta = with lib; {
    description = "pulls the list of emails from a mailbox, using the subject lines as TODOs, and generates a HTML page as resulting output.";
    homepage = "https://git.sr.ht/~artemis/todo-imap-to-html";
    mainprogram = "todo-imap-to-html";
  };
}
