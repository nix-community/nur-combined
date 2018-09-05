{ stdenv, path, fetchurl, callPackage }:

let
  # Note: the version MUST be one version prior to the version we're
  # building
  version = "2018-09-05";

  # fetch hashes by running `print-hashes.sh nightly 2018-09-05`
  hashes = {
		i686-unknown-linux-gnu = "f108eafc9f522d22c8a8a22339cc19f8dbc746d9fa1dc923f7c3dc3ba37f1960";
		x86_64-unknown-linux-gnu = "a920fa4671122259787feaeedf1202f82f696e81a4de0b66d25b7b10d3e59629";
		armv7-unknown-linux-gnueabihf = "327eee1379d28973cde2463527f04d85014a166e646578b83d9a2ccc55b0d626";
		aarch64-unknown-linux-gnu = "6c746bc4f1b9a2aec5bfe125a8669b5d8c0a8223a223621abaa1a7f11fefdf48";
		i686-apple-darwin = "b43cf1af7c469e90588a44d98c35955b736b0eda47e472bba54a9b9ec8a4553d";
		x86_64-apple-darwin = "e7310d26a8cd9142d41a81d42e2c1325207af968669368936cd1c860560017e9";
  };

  platform =
    if stdenv.hostPlatform.system == "i686-linux"
    then "i686-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "x86_64-linux"
    then "x86_64-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "armv7l-linux"
    then "armv7-unknown-linux-gnueabihf"
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then "aarch64-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "i686-darwin"
    then "i686-apple-darwin"
    else if stdenv.hostPlatform.system == "x86_64-darwin"
    then "x86_64-apple-darwin"
    else throw "missing bootstrap url for platform ${stdenv.hostPlatform.system}";

  src = fetchurl {
     url = "https://static.rust-lang.org/dist/${version}/rust-nightly-${platform}.tar.gz";
     sha256 = hashes."${platform}";
  };

in callPackage (path + "/pkgs/development/compilers/rust/binaryBuild.nix") {
 inherit version src platform;
 buildRustPackage = null;
 versionType = "bootstrap";
}
