{ lib, fetchFromGitHub, rustPlatform, udev, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "rust-u2f";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "danstiner";
    repo = pname;
    rev = "a19b0084d6367d5cf9dd050598dfda35327e4c6c";
    hash = "sha256-i0M86u3QuxwdS8KfF466GuJfoVc7I0OcNFfxHi9uZuE=";
  };

  cargoSha256 = "sha256-tdv9tCoPUVMtAYnyYllY3MJPHgfYQpUdDDgesRJBAM0=";

  nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];

  buildInputs = [ udev openssl ];

  meta = with lib; {
    description = "U2F security token emulator written in Rust";
    homepage = "https://github.com/danstiner/rust-u2f";
    license = with licenses; [ asl20 ];
  };

}
