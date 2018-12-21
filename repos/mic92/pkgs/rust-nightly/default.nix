{ stdenv, path, fetchurl, callPackage }:

let
  # Note: the version MUST be one version prior to the version we're
  # building
  version = "2018-12-21";

  # fetch hashes by running `print-hashes.sh nightly 2018-09-05`
  hashes = {
    i686-unknown-linux-gnu = "fd652339a9c7ae5582aee0883370d35a096a67139a24e009a41dac56ab053954";
    x86_64-unknown-linux-gnu = "c207d7ebab375e046bae7e1326d38c9ff4ff20da5d21591a2e77315846c0d1d9";
    armv7-unknown-linux-gnueabihf = "77b1262ade8e6b0ce7c69b7e623445c544fdd43261bc9477b5b6b7c3d8664522";
    aarch64-unknown-linux-gnu = "cc0fc6e75fd6518828fc18fd9cbfb7103ab7ff39be3ad42ffd3514594c365f4d";
    i686-apple-darwin = "4b27738d427f71fe4a7ddbcef079afc8d5992d65d58f7f9d89f8838637949b2f";
    x86_64-apple-darwin = "d0ec3cfd33f5da3dcb6818fd754f3a309e9ad47f879e8511ee1baeb3365f7a89";
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
