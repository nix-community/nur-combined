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
  {
    pname = "realm";
    version = "2.7.0-unstable";
    src = fetchFromGitHub {
      owner = "zhboner";
      repo = "realm";
      rev = "3c839d55eb64d6c1e6af2ba9d63e484034a05cfe";
      hash = "sha256-YRfMXHlYgcjmq+uw3+Nefu5fng3v0MYpIAhdTQbsWSE=";
    };

    cargoHash = "sha256-5pp9H2+Aar5ZjOGaA4PlJ8ZiS5gu27Xdr0Rjzp9DJDw=";

    meta.mainProgram = "realm";
  }
