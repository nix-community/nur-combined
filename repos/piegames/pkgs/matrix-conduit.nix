{ lib, rustPlatform, fetchgit, pkgconfig, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "matrix-conduit";
  version = "unstable-2020-08-25";

  src = fetchgit {
    url = "https://git.koesters.xyz/timo/conduit.git";
    rev = "6343eea4178336e50b77b5113d020516405b4dc6";
    sha256 = "0q21c4f0v3k6fp1kpbs4zjhcly2mna3pwf74b5fq7q0p5371458w";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ openssl ];

  cargoSha256 = "1ilpw4pzm8fqim29jzwlfgz1jyblragalm50vqyj1n14piapxzlk";

  meta = with lib; {
    description = "A Matrix homeserver written in Rust";
    homepage = "https://conduit.rs";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
