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
  version = "0.18.4";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "affromero";
    repo = "gitpane";
    rev = "v${version}";
    hash = "sha256-Lnr+kn+rfq8F9pdoCFaP/xHxw1nkDPsz9wr1D0oGYqs=";
  };

  cargoHash = "sha256-HwyaxKTsRBkmLQbZP444o4q0YL2MSja1r8dy43DGhoE=";

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
