{ sources, pkgs, darwin, stdenv, rustPlatform, fetchFromGitHub, ... }:
with pkgs;
rustPlatform.buildRustPackage rec {
  pname = "lfs";
  version = "master";
  src = fetchFromGitHub { inherit (sources.lfs) owner repo rev sha256; };
  cargoSha256 = "1zj50nni3j1i8s5km355x0lczmrza5zjkfkq3p61ki0xksns2858";
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin
    darwin.apple_sdk.frameworks.IOKit;

  meta = with lib; {
    homepage = "https://github.com/Canop/lfs";
    description = "A small linux utility listing your filesystems.";
    license = licenses.mit;
  };
}
