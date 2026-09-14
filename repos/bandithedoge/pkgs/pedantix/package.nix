{
  lib,
  nix-update-script,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pedantix";
  version = "1.2.2";
  src = fetchFromGitHub {
    owner = "Swarsel";
    repo = "pedantix";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nDAJ7Th/e08LPseucE9lBfcNgZUURdlrI9IShm86WZM=";
  };

  cargoHash = "sha256-u9Fn1GphndiUlIWRBHMKVP/9N0CYOPAQUwLvpAVysrM=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The pedantic nix formatter";
    homepage = "https://swarsel.github.io/pedantix";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "pedantix";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
