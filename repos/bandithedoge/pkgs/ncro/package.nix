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
  version = "2.2.2";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "ncro";
    rev = "v${finalAttrs.version}";
    hash = "sha256-attdCg/FjUooYxVidEDR5wVeQ8aAPAj4b6HQVL17Tng=";
  };

  cargoHash = "sha256-woqDFlQ8r/8KMVLW6K8ucrMPBNZklqmiaaAevQnzbPk=";

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
