{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  perl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Jtpi75JH2LIlrfNTVDwePYNqVuBYRPGyG/f1aZuTmUw=";
  };

  cargoHash = "sha256-5+hgRI3XyPdRcefSokYUXHrgjp2k8i1+9D3lCujm9uk=";

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
