{
  clangStdenv,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } (finalAttrs: {
  pname = "nixtopsy";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "nixtopsy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9bRgcG72LFGjlD5HyODxUd5Fo9YrnUdbIrixc90DZjU=";
  };
  cargoHash = "sha256-OL5Hrz9tpf0iwbcxavoydw6ImoIf5Aiu9B7ARc9vRnw=";

  env.RUSTFLAGS = "-Clinker=clang";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interactively dissect your Nix closures";
    homepage = "https://github.com/manic-systems/nixtopsy";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "nixtopsy";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
