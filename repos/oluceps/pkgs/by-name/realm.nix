{
  fetchFromGitHub,
  fenix,
  makeRustPlatform,
}:
let
  inherit (fenix.minimal) toolchain;
in

(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  rec {
    pname = "realm";
    version = "2.7.0";

    src = fetchFromGitHub {
      owner = "zhboner";
      repo = "realm";
      rev = "v${version}";
      hash = "sha256-vkLGfSDRYqvoqyVM/CWGJjpvXXPisEZxUSjLZGjNzno=";
    };

    cargoHash = "sha256-eJI1pr0zjBRmMW1+XYjAYJHM/TEMbQJGPHsgcrcc3RA=";

    meta.mainProgram = "realm";
  }
