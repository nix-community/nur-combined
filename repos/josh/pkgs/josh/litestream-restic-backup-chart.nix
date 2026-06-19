{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "litestream-restic-backup-chart";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "litestream-restic-backup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G7PNvg0elqEK/QSrI7X6WfjMZLxn0y0lW/1wHsEaTiM=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/litestream-restic-backup/* $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "A Helm chart for litestream-restic-backup";
    homepage = "https://github.com/josh/litestream-restic-backup/tree/main/charts/litestream-restic-backup";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
