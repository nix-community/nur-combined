{
  lib,
  rustPlatform,
  fetchCrate,
}:

rustPlatform.buildRustPackage rec {
  pname = "keres-cli";
  version = "0.7.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-7cIZ/BYUghhYw6gAZ/D1++HS5acEPqpHXIOWs0fC0tk=";
  };

  cargoHash = "sha256-QUQH5AfypgQKKRLcOAcUFuV+44vVIq2albD4bLvP8wc=";  

  meta = {
    description = "Command-line interface for the Keres";
    homepage = "https://github.com/keres-rs/keres-cli";
    license = lib.licenses.asl20;
    mainProgram = "keres";
  };
}

