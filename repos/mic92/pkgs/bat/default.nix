{ stdenv, fetchFromGitHub, rustPlatform, git, cmake, zlib }:

rustPlatform.buildRustPackage rec {
  name = "bat-${version}";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "bat";
    rev = "v${version}";
    sha256 = "1ramp8hb8b6zia8598z8jyavndk3k1y5fs1jhz1la4vss21n7fw6";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ git zlib ];

  cargoSha256 = "062vvpj514h85h9gm3jipp6z256cnnbxbjy7ja6bm7i6bpglyvvi";

  meta = with stdenv.lib; {
    description = "A cat(1) clone with wings.";
    homepage = "https://github.com/sharkdp/bat";
    license = licenses.mit;
  };
}
