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
  version = "0.7.4";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5TP0cvR9pG+6sd0ZNqTQrIHYEXLzmfEj/TDBI6tWbIA=";
  };

  cargoHash = "sha256-CnF7KAwZOI9TaUJttLyY/FFkniIdidFIN8bHEQULN9M=";

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
