{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "dogma";
  version = "2.2.0"; # without "v"

  src = fetchFromGitHub {
    owner = "x71c9";
    repo = "dogma";
    rev = "v${version}";
    hash = "sha256-R1Gc0nwDW9IfYOWPwv+H1eke6cYiQTA4bKox0v9AExI=";
  };

  cargoLock.lockFile = ./Cargo.lock;


  doCheck = false;

  mainProgram = "dogma";

  meta = with lib; {
    description = "Bridges secrets from vault backends and infrastructure outputs into sops-encrypted files deployed to NixOS machines";
    homepage = "https://github.com/x71c9/dogma";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
