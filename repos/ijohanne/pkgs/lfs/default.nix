{ sources, pkgs, darwin, stdenv, rustPlatform, fetchFromGitHub, ... }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "lfs";
  version = "master";
  src = fetchFromGitHub { inherit (sources.lfs) owner repo rev sha256; };
  cargoSha256 = "1d718qqkk36n19hp9igv6qxb6sv1i0na0i6clpcxfy7zsagxqwc0";
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin
    darwin.apple_sdk.frameworks.IOKit;

  meta = with lib; {
    homepage = "https://github.com/Canop/lfs";
    description = "A small linux utility listing your filesystems.";
    license = licenses.mit;
  };
}
