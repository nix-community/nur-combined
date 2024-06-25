{ lib, fetchCrate, rustPlatform, pkg-config, cmake, git, udev }:
rustPlatform.buildRustPackage rec {
  pname = "probe-rs-tools";
  version = "0.24.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "0zlgqkk88hj3n14z5p00ns55pp9p6znw87i5v60b9b2isyv648xq";
  };

  cargoHash = "sha256-iIL1QDvWaMfaOcXmmsPy/SyyIWKadwvhAqDqhCVgpy8=";
  doCheck = false;

  nativeBuildInputs = [ pkg-config cmake git ];
  buildInputs = [ udev ];
}
