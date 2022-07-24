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

  cargoSha256 = "04ghk7803s1dqfrs51kydgpqmkz67frqqzjb4xgbbi6krdcq9kdf";

  meta = with lib; {
    description = "Demangle Rust symbols";
    homepage = "https://github.com/luser/rustfilt";
    license = with licenses; [ asl20 ];
  };
}
