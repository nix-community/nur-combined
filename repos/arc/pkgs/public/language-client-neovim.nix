{ lib, stdenv, fetchurl, rustPlatform, darwin }: let
  pname = "LanguageClient-neovim";
  version = "0.1.156";
  src = fetchurl {
    url = "https://github.com/autozimu/LanguageClient-neovim/archive/${version}.tar.gz";
    sha256 = "0bf2va6lpgw7wqpwpfidijbzphhvw48hyc2b529qv12vwgnd1shq";
  };
in rustPlatform.buildRustPackage {
  inherit pname src version;

  cargoSha256 = if lib.isNixpkgsStable
    then "1w8g7pxwnjqp9zi47h4lz2mcg5daldsk5z72h8cjj750wng8a82c"
    else "0rp4zic2bgb781v92zzdch9wazrc9j8a44b1wxsqjbpqazy0izcw";
  buildInputs = with darwin.apple_sdk.frameworks; lib.optionals stdenv.isDarwin [ CoreFoundation CoreServices ];
  meta.broken = lib.versionAtLeast "1.40.0" rustPlatform.rust.rustc.version;
}
