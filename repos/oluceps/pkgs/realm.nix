{ fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "realm";
  version = "2.5.4";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "zhboner";
    repo = pname;
    hash = "sha256-RBsCxlVvMNRqhs9FhvGiWIUutfjT2NvIBhyaKYBN3lo=";
  };

  cargoHash = "sha256-chGSrkPgPDI/8i+ZbHgh+DzjnY159ucwottIUW8NqFY=";

  RUSTC_BOOTSTRAP = 1;
}
