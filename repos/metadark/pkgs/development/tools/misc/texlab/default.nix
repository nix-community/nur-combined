{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, installShellFiles
, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "texlab";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "latex-lsp";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-NfWrpYt11z8jZo6jWQ3eCz+rp2IxSG/16kTwdy+Rpxs=";
  };

  cargoHash = "sha256-fh6ioQixZ5Plu9utcFKOpm4LMePctM/6BPpCYS/1/T8=";

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = lib.optionals stdenv.isDarwin [ Security ];

  postInstall = ''
    installManPage texlab.1
  '';

  meta = with lib; {
    description = "An implementation of the Language Server Protocol for LaTeX";
    homepage = "https://texlab.netlify.app";
    license = licenses.mit;
    maintainers = with maintainers; [ doronbehar metadark ];
  };
}
