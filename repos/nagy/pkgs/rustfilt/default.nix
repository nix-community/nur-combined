{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "rustfilt";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "luser";
    repo = pname;
    rev = version;
    sha256 = "096219q0d2i3c2awczlv64dnyjpx2b5ml8fgd2xwly56wn8nvgfd";
  };

  cargoSha256 = "19lkvmg5ii731iz1wkji959qq4gx1m9wvpr7l9x6f8f92v697n34";

  meta = with lib; {
    description = "Demangle Rust symbols";
    homepage = "https://github.com/luser/rustfilt";
    maintainers = with maintainers; [ ];
    license = with licenses; [ asl20 ];
  };
}
