{ stdenv, path, fetchurl, callPackage }:

let
  # Note: the version MUST be one version prior to the version we're
  # building
  version = "2019-01-16";

  # fetch hashes by running `print-hashes.sh nightly 2018-09-05`
  hashes = {
    i686-unknown-linux-gnu = "ff02150370ab010e0a70448b800218d784379f058839d49b4f8b97eaf0477815";
    x86_64-unknown-linux-gnu = "a36242dfe35d172eeaf5b56eec8547b7d5940dee34fc2c8376bbb0882f17f129";
    armv7-unknown-linux-gnueabihf = "ac3da9bea3f85e2dd2d2db0e1a6be41a05884648b9b5c98b22463c59d01d3469";
    aarch64-unknown-linux-gnu = "05eb868659a64fa1440b84c0546c3734a0b1fd27961eee3743182c179ae27686";
    i686-apple-darwin = "5bd3470c0ee64fc019c53ea93b2abd5315e0dfa0c449c75fc3c0d3ab1dfe8438";
    x86_64-apple-darwin = "ba006f685b8651343eb7e43a0d9b5f89b18518767eea320cf5db4655b2d2bef3";
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
 versionType = "bootstrap";
}
