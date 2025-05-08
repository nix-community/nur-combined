{ fetchCrate
, lib
, nix-update-script
, rustPlatform

  # Dependencies
, nasm
}:

rustPlatform.buildRustPackage (cavif: {
  pname = "cavif";
  version = "1.5.6";

  src = fetchCrate {
    inherit (cavif) pname version;
    sha256 = "sha256-vUmf9kTG3Gm4SH0gRf0NUK7Rr0Xq0BHNW2//5y4jMXY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ZMrpisAxcdXCQRzKdLQrnIYRTBCxC+R22+cGZSFFiYg=";

  nativeBuildInputs = [ nasm ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "AVIF image creator in pure Rust";
    homepage = "https://github.com/kornelski/cavif-rs";
    license = lib.licenses.bsd3;
  };
})
