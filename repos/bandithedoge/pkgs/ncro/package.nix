{
  clangStdenv,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  wild,
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } (finalAttrs: {
  pname = "ncro";
  version = "2.4.0";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "ncro";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xuMwlDKryFsd+wYA1sQSJZWoU4f+c3/tqs2rb8sSfXg=";
  };

  cargoHash = "sha256-twPCq6VEAWezccoP4c/UqIgIgseXwQa60zxHsZE4fbU=";

  nativeBuildInputs = [ wild ];

  doCheck = false;

  env.RUSTFLAGS = "-Clinker=clang";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight HTTP proxy for optimizing Nix cache routes for fast access";
    homepage = "https://github.com/manic-systems/ncro";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "ncro";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
