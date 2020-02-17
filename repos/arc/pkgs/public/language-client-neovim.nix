{ lib, stdenv, fetchurl, rustPlatform, darwin }: let
  pname = "LanguageClient-neovim";
  version = "0.1.146";
  src = fetchurl {
    url = "https://github.com/autozimu/LanguageClient-neovim/archive/${version}.tar.gz";
    sha256 = "1xm98pyzf2dlh04ijjf3nkh37lyqspbbjddkjny1g06xxb4kfxnk";
  };
in rustPlatform.buildRustPackage {
  inherit pname src version;

  cargoSha256 = "0dixvmwq611wg2g3rp1n1gqali46904fnhb90gcpl9a1diqb34sh";
  legacyCargoFetcher = true;
  buildInputs = with darwin.apple_sdk.frameworks; lib.optionals stdenv.isDarwin [ CoreFoundation CoreServices ];
}
