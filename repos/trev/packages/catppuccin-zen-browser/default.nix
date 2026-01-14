{
  stdenv,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "catppuccin-zen-browser";
  version = "0-unstable-2025-09-28";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "zen-browser";
    rev = "c855685442c6040c4dda9c8d3ddc7b708de1cbaa";
    hash = "sha256-5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
  };

  dontBuild = true;

  installPhase = ''
    cp -r themes "$out"
  '';

  passthru = {
    updateScript = lib.concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=main"
        "catppuccin-zen-browser"
      ];
    });
  };

  meta = {
    description = "Catppuccin theme for Zen Browser";
    homepage = "https://github.com/catppuccin/zen-browser";
    changelog = "https://github.com/catppuccin/zen-browser/commits/main";
    platforms = lib.platforms.all;
  };
}
