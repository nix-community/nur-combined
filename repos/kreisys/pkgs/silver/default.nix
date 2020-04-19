{ darwin, sources, stdenv, rustPlatform, openssl, pkgconfig, libiconv }:

rustPlatform.buildRustPackage rec {
  pname   = "silver";
  version = sources.silver.version;
  src     = sources.silver;

  buildInputs = [ pkgconfig openssl libiconv ]
              ++ stdenv.lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  cargoSha256 = "sha256:1hfb5w8l36cdzj4xi2bsj9l9pgdkbf3k2b1w4diqgaj2qnwywvqd";
  # cargoSha256 = "sha256:0iwgipj6vpc6gy06m873lylzv3fbsmc6srk9lqnyc2zik3h3v9la";

  # wanted: sha256:0iwgipj6vpc6gy06m873lylzv3fbsmc6srk9lqnyc2zik3h3v9la
  # got:    sha256:1hfb5w8l36cdzj4xi2bsj9l9pgdkbf3k2b1w4diqgaj2qnwywvqd
  meta = with stdenv.lib; {
    inherit (sources.silver) description homepage;
    license   = licenses.unlicense;
    platforms = platforms.all;
  };
}
