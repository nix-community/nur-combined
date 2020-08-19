{pkgs, fetchgit}:

pkgs.rustPlatform.buildRustPackage rec {
  name = "matrix-conduit-${version}";
  version = "unstable-2020-08-19";
  src = (fetchgit {
    url = "https://git.koesters.xyz/timo/conduit.git";
    rev = "cfda76860b7d1e32fc8c2e2e93f0695eed6a550e";
    sha256 = "0n30m9zwjqwcgy00svd7qdfdd7bfnqn6b2qmixias2h3iafgfb1q";
  });
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  checkPhase = "";
  cargoSha256 = "sha256:183i23p9256a4sv88jlk81qkyiyi44mhg53jlx1gjigqdk8471gk";

  meta = with pkgs.stdenv.lib; {
    description = "A Matrix homeserver written in Rust";
    homepage = "https://conduit.rs";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
