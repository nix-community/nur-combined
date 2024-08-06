{ lib

, fetchFromGitHub

, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "enquirer";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "termapps";
    repo = "enquirer";
    rev = "v${version}";
    hash = "sha256-Bb5oRavoT56wCvG/Xii51nvkJrc9rHg/pjo4lNMi6i8=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "Command line utility for stylish interactive prompts";
    homepage = "https://github.com/termapps/enquirer";
    changelog = "https://github.com/termapps/enquirer/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "enquirer";
  };
}
