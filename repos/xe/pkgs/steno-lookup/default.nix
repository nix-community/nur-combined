{ stdenv, fetchFromGitHub, rustPlatform, pkg-config, libX11, libXrandr }:

rustPlatform.buildRustPackage rec {
  pname = "steno-lookup";
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  version = "0.1.0";
  cargoSha256 = "1j3fgifcx6ipq2q2sn6w6sgpg7bj9jy2y5z2s38pphwijb2wrd1s";
  verifyCargoDeps = true;
  legacyCargoFetcher = true;
  meta = with stdenv.lib; {
    maintainers = with maintainers; [ xe ];
  };
}
