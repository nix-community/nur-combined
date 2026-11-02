{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.7.0";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XKF7V4p3He4TR6GGvclLzvhTGvHxxp92OB955VKLVXE=";
  };

  cargoHash = "sha256-H/LuhS6tGgYnlxTV3wCSh18xsDnjQ6QAss9r2ChDKdo=";

  nativeBuildInputs = [ perl ];

  passthru.updateScript = nix-update-script { };

  checkFlags = [ "--skip=cmd::tui::tests" ];

  meta = {
    description = "Efficient AI coding agent extendable by neovim-like Lua plugins";
    homepage = "https://maki.sh";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "maki";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
