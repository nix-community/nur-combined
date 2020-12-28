{ stdenv, rustPlatform, fetchFromGitHub, pkg-config, alsaLib, xorg, python3, openssl }:
rustPlatform.buildRustPackage rec {
  pname = "ruffle";
  version = "nightly-2020-11-29";

  src = fetchFromGitHub {
    owner = "ruffle-rs";
    repo = pname;
    rev = version;
    sha256 = "1q7v6g8r1jrhgdx09b73wnlykman1043y00q6bp8svp59bnjibsv";
  };

  nativeBuildInputs = [ pkg-config python3 ];

  buildInputs = [ alsaLib xorg.libX11 openssl ];

  cargoSha256 = "1wdh0rjjqy0r4z89qpc8jkwfc53lfsp1wr9p57s1qfkm6dzcxvi3";

  meta = {
    description = "A Flash Player emulator written in Rust";
    homepage = https://github.com/ruffle-rs/ruffle;

    license = stdenv.lib.licenses.asl20;
    maintainers = [];
    platforms = stdenv.lib.platforms.linux;
  };
}
