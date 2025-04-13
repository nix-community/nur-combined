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

    cargoHash = "sha256-Oe64l16uYdU6NvTl7XrEm6dAtRFngI9yHC4fe4hpTNA=";

    meta.mainProgram = "realm";
  }
