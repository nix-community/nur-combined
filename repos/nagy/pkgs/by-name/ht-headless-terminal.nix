{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ht";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "andyk";
    repo = "ht";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UJAKtdzuzPHc5t67ui8sptzl5Gz+kkrgILkmfstNcJ0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-IygZS5BthWbzoHQcgi1MVxQ71Yv1WIxqHn3nGm4G/rw=";

  meta = {
    description = "Headless terminal - wrap any binary with a terminal interface for easy programmatic access";
    homepage = "https://github.com/andyk/ht";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ht";
  };
})
