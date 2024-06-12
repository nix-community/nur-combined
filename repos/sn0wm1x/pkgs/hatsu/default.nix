{ cmake
, fetchFromGitHub
, lib
, openssl
, pkg-config
, rustPlatform
}:
let
  pname = "hatsu";
  version = "0.2.0";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "importantimport";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gBzhuV0SDmNwl5PkpdGxkMBn5m4vEXfv23WK7+ZzQs8=";
  };

  cargoHash = "sha256-A2tl0jjKODA/qodxkIe/3V4ZDGV4X0myiduJsLtd7r0=";

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ openssl ];

  env = { OPENSSL_NO_VENDOR = true; };

  meta = with lib; {
    homepage = "https://github.com/importantimport/hatsu";
    description = "Self-hosted & Fully-automated ActivityPub Bridge for Static Sites.";
    license = licenses.agpl3Only;
    mainProgram = pname;
    # maintainers = with maintainers; [ kwaa ];
  };
}
