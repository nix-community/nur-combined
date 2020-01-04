{ darwin, sources, stdenv, rustPlatform, openssl, pkgconfig, libiconv }:

rustPlatform.buildRustPackage rec {
  pname   = "silver";
  version = sources.silver.version;
  src     = sources.silver;

  buildInputs = [ pkgconfig openssl libiconv ]
              ++ stdenv.lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  cargoSha256 = "sha256-iqY94JjxC+YtpmlmbVjVy439qafjoGqAf4bdbeSNj0c=";

  meta = with stdenv.lib; {
    inherit (sources.silver) description homepage;
    license   = licenses.unlicense;
    platforms = platforms.all;
  };
}
