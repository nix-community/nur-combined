{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, lua
, git
, cmake
, gnumake
, perl
}:
let
  pname = "proxelar";
  version = "0.6.0";
  owner = "emanuele-em";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-+6iwryj77zO2tkjGerTANwiraCWeaTVCNHgizNWhf1o=";
  };

  cargoHash = "sha256-ZS1NJEstdieJ7x++eafO9MtmGKnwoWLQt1ine5jLTqI=";

  nativeBuildInputs = [ pkg-config git cmake gnumake perl rustPlatform.bindgenHook ];

  buildInputs = [ openssl lua ];

  # There is no tests
  doCheck = false;

  meta = {
    description = "Programmable MITM proxy that intercepts HTTP/HTTPS traffic. With a TUI, terminal, and web GUI interface";
    homepage = "https://github.com/emanuele-em/proxelar";
    changelog = "https://github.com/emanuele-em/proxelar/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "proxelar";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
