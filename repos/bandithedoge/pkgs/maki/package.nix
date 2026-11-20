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
  version = "0.7.3";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HSkefH0xY/XipjF2dGWGg2pNbweFH0qyX+88vaeUKmk=";
  };

  cargoHash = "sha256-cgv82OcT6Ub8/7s1h/YN9wCwOXURhc6erf9NviWWAww=";

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
