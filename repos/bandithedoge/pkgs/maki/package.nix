{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.6.5";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xRpMH/0j7aiCFXKKoiDlVC4wm/TGGMCte7YEBuzdDgY=";
  };

  cargoHash = "sha256-Gfp8gE7brcs5lb4uojQqtcOzdTkd0JRQJkhREeLQc9M=";

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
