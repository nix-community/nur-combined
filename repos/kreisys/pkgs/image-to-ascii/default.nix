{ stdenv, rustPlatform, sources }:

let
  inherit (stdenv.lib) substring;
  src = sources.image-to-ascii;
in rustPlatform.buildRustPackage rec {
  pname = "image-to-ascii";
  version = substring 0 7 src.rev;

  inherit src;

  cargoSha256 = "sha256:01i8i8p08rcz61i1mmmz54lzm69w0miq2gdy2zkgzcccyv6p3xv5";

  meta = {
    inherit (src) description;
    platforms = stdenv.lib.platforms.unix;
  };
}
