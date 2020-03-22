{ stdenv, rustPlatform, fetchzip }:
let
  repo = "https://git.sr.ht/~priegger/rust-hello-world";
  rev = "35c7974bc84d538283dea515d86b847d15f61591";
in
rustPlatform.buildRustPackage {
  name = "rust-hello-world";

  src = fetchzip {
    url = "${repo}/archive/${rev}.tar.gz";
    sha256 = "16xyirv3sg9jjp3h2h13s3a5hrnvwlymvqzzchzdl2xii71vj891";
  };

  cargoVendorDir = "vendor";

  meta = with stdenv.lib; {
    description = "Hello World in Rust";
    homepage = repo;
    license = licenses.mit;
  };
}
