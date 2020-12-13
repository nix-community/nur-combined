{ lib, rustPlatform, fetchgit, pkgconfig, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "matrix-conduit";
  version = "unstable-2020-11-06";

  src = fetchgit {
    url = "https://gitlab.com/famedly/conduit";
    rev = "18f33b1ece291797f22b27e186f93b21a423341c";
    sha256 = "16d6sy6l66dq902wq63wv793a1zf6dzfvi5njhc4xf2lxwrsm4wv";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  cargoSha256 = "1lg38aw2chpfpif7sic634jxdp2mrb0gxbm2l1zkzw63g1c6xylm";

  meta = with lib; {
    description = "A Matrix homeserver written in Rust";
    homepage = "https://conduit.rs";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
