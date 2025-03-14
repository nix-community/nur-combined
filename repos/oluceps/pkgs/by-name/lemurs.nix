{
  linux-pam,
  fenix,
  fetchFromGitHub,
  makeRustPlatform,
  rustPlatform,
  ...
}:
# let
#   inherit (fenix.minimal) toolchain;
#   rustPlatform = (
#     makeRustPlatform {
#       cargo = toolchain;
#       rustc = toolchain;
#     }
#   );
# in
rustPlatform.buildRustPackage {
  name = "lemurs";
  version = "0.3.2-patch";
  src = fetchFromGitHub {
    owner = "coastalwhite";
    repo = "lemurs";
    rev = "1d4be7d0c3f528a0c1e9326ac77f1e8a17161c83";
    hash = "sha256-t/riJpgy0bD5CU8Zkzket4Gks2JXXSLRreMlrxlok0c=";
  };
  cargoHash = "sha256-Cwgu30rGe1/Mm4FEEH11OTtTHUlBNwl5jVzmJg5qQe8=";
  useFetchCargoVendor = true;

  buildInputs = [
    linux-pam
  ];
}
