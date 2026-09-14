{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.5.3";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mJFvNpbtYPb0wSsHvKYGFnk48tK5L9vVGg9elzEgXRA=";
  };

  cargoHash = "sha256-l8Lu+7hQzZ9D5Vhs0R+0J6EtgO07UM/9IeAy/224zaU=";

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
