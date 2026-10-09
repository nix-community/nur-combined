{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.5.7";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HcTlxua+N/O2qHT67q96b/TT/gIIcsS+OwCM8X7udrM=";
  };

  cargoHash = "sha256-zRc7zvhTMUaP3BkRC+OZlQnMwreFMe3VeONXPImeX98=";

  nativeBuildInputs = [ perl ];

  # XXX: waiting for https://github.com/NixOS/nixpkgs/pull/569018
  # passthru.updateScript = nix-update-script { };

  meta = {
    description = "Efficient AI coding agent extendable by neovim-like Lua plugins";
    homepage = "https://maki.sh";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "maki";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
