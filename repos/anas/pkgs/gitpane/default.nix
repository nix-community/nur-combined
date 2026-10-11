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
  version = "0.17.1";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "affromero";
    repo = "gitpane";
    rev = "v${version}";
    hash = "sha256-v7rH/dQ8UDSPBpRL7ORowZcPUBanXD29z9VkPXv71Gc=";
  };

  cargoHash = "sha256-vmSQ5fAyPlBvBDD350kV2tCJCIP2oEUQAaW4vhrJCog=";

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
