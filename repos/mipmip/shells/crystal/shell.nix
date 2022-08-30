with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "crystal";

#THIS IS ESSENTIAL TO MAKE CRYSTAL WORK
nativeBuildInputs = [
  pkg-config
  cmake
];
buildInputs = [
  openssl
  crystal
  shards
  webkitgtk
  cmake
];
}




