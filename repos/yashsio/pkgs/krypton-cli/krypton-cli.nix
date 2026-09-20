{ lib
, rustPlatform
, fetchCrate
}:

rustPlatform.buildRustPackage rec {
  pname = "krypton-cli";
  version = "0.4.1";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-sZ4j0s7qVJ89VWnsx1Su4m/6fFE4I+UKeKTt4OK9Vbg=";
  };

  cargoHash = "sha256-KBEVGZJkscjNJVyv5b1TgjuyzQKuD6o0e5Fnr+QjhXE=";

  meta = {
    description = "Command-line interface for the Krypton encryption library";
    homepage = "https://crates.io/crates/krypton-cli";
    license = lib.licenses.asl20;
    mainProgram = "krypton";
  };
}

