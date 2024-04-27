{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "wally";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "UpliftGames";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-lbEUj6iWwm3KtfUwNkJf8cSjXMQ4Mki/jAqQavDajUA=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock; 
    outputHashes = {
         "rocket-0.5.0-rc.3" = "sha256-V6Kusn5ZIClIG6Cd1GtVtuJYw2FsT2PNVVQG0vhRrsE=";
       };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "A modern package manager for Roblox projects";
    homepage = "https://wally.run";
    changelog = "https://github.com/UpliftGames/wally/tree/v${version}/CHANGELOG.md";
    license = licenses.mpl20;   
  };
}
