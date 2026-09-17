{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.5.5";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6IEdSMLeL0dmDynBS3qCEPxrW8wN/FyJDgojjqmZn7g=";
  };

  cargoHash = "sha256-Y30sGDJyA3SRWxBQLqBhSW7zyAYdAh4qFzLcuEWkeYM=";

  nativeBuildInputs = [ perl ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Efficient AI coding agent extendable by neovim-like Lua plugins";
    homepage = "https://maki.sh";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "maki";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
