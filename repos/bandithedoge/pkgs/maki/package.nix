{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  aws-lc,
  perl,
  pkg-config,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.7.2";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zV+J2fMaa8JUWyP0veQT6Le9s0t4iHHmKWhmPXPrATQ=";
  };

  cargoHash = "sha256-Ld0mj+4URAUMjMyCfDW8dBK8dSse28c4FTcxkLh1mQY=";

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    aws-lc
  ];

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
