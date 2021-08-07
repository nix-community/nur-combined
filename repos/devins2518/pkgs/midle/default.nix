{ lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "midle";
  version = "unstable-2021-08-07";

  src = fetchFromGitHub {
    owner = "snakedye";
    repo = pname;
    rev = "8f9224ada9141bd93baef9b5aa8af4a1cccded24";
    sha256 = "sha256-uDQLlklMebb6WM9G566ZtEP2XxaQLbtGGPKBn930YME=";
  };

  cargoSha256 = "sha256-CdkavLURzRwVoxWT8ZjewSHm9JjLfVm462hYD4Tp9+k=";

  meta = with lib; {
    description = "The mediocre idle client";
    homepage = "https://github.com/snakedye/midle";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
