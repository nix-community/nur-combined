{
  pam,
  fenix,
  fetchFromGitHub,
  makeRustPlatform,
  ...
}:
let
  inherit (fenix.minimal) toolchain;
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    name = "lemurs";
    version = "0.3.2-patch";
    src = fetchFromGitHub {
      owner = "coastalwhite";
      repo = "lemurs";
      rev = "1d4be7d0c3f528a0c1e9326ac77f1e8a17161c83";
      hash = "sha256-t/riJpgy0bD5CU8Zkzket4Gks2JXXSLRreMlrxlok0c=";
    };
    cargoHash = "sha256-NlcILzwY3x4LJW4BcmD0YyxJHez/UBq6U6J3iZuj1I0=";

    buildInputs = [
      pam
    ];
  }
