{ fetchCrate
, lib
, nix-update-script
, rustPlatform

  # Dependencies
, nasm
}:

rustPlatform.buildRustPackage rec {
  pname = "cavif";
  version = "1.5.6";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-vUmf9kTG3Gm4SH0gRf0NUK7Rr0Xq0BHNW2//5y4jMXY=";
  };

  cargoHash = "sha256-Q7fiKr8a8QlvEPUMYDkTqMeQU2+BPequnjXBhgu+3Mc=";

  nativeBuildInputs = [ nasm ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AVIF image creator in pure Rust";
    homepage = "https://github.com/kornelski/cavif-rs";
    license = lib.licenses.bsd3;
  };
}
