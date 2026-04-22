{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "esp-config";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "esp-rs";
    repo = "esp-hal";
    rev = "refs/tags/esp-hal-v${version}";
    hash = "sha256-P+W1QlDO0tg277837FLS+Ko3my3HswgOSYq3zjS6Q9g=";
  };

  buildAndTestSubdir = "esp-config";
  buildFeatures = ["tui"];

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "Configure projects using esp-hal and related packages";
    homepage = "https://github.com/esp-rs/esp-hal/tree/main/esp-config";
    license = with licenses; [mit asl20];
    mainProgram = "esp-config";
    maintainers = [];
  };
}
