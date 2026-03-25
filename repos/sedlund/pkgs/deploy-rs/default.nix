{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "deploy-rs";
  version = "0-unstable-2026-02-06";

  src = fetchFromGitHub {
    owner = "neunenak";
    repo = "deploy-rs";
    rev = "7a1afb23e106b3a48ac2f7c45fa5f028156c34f2";
    hash = "sha256-rK5kc0rEoOPOI+nFINbPw6IB7dTmhBPTfPptxys7WtA=";
  };

  cargoHash = "sha256-Fl1FuCt/DzWrG2DxCw7Ifc1sf1wthh497lGvkEgsjis=";

  meta = {
    description = "Multi-profile Nix-flake deploy tool";
    homepage = "https://github.com/neunenak/deploy-rs";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ sedlund ];
    mainProgram = "deploy";
    platforms = lib.platforms.unix;
  };
}
