{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, git
, perl
}:

let
  pname = "gitpane";
  version = "0.18.13";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "affromero";
    repo = "gitpane";
    rev = "v${version}";
    hash = "sha256-sYtzjmNy6MQhFCz40Ngf89vWdmjGiWh09yLqeUNVNPw=";
  };

  cargoHash = "sha256-EJwjx0SNWFzyvuSxEL8z4Hf+BYngeFB8i9XmTTG9tYg=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    git
    openssl
  ];

  # There is no tests
  doCheck = false;

  meta = {
    description = "Multi-repo Git workspace dashboard for the terminal";
    homepage = "https://github.com/affromero/gitpane";
    license = lib.licenses.mit;
    mainProgram = "gitpane";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
