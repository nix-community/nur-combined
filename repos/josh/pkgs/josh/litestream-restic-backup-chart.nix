{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nur,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "litestream-restic-backup-chart";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "litestream-restic-backup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VAEWBUEXFVgW7W+7QHtR+cCAL3m+3Y5hyB721svijR8=";
  };

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/litestream-restic-backup/* $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    render = nur.repos.josh.renderHelmTemplate {
      src = finalAttrs.finalPackage;
      chartName = "litestream-restic-backup";
      helmValues = {
        litestream.replicaURL = "s3://backup-bucket/db";
        restic.repository = "s3:https://s3.example.com/restic";
      };
    };
    images = nur.repos.josh.checkKubeImages {
      src = finalAttrs.passthru.tests.render;
      inherit (finalAttrs) pname version;
    };
  };

  meta = {
    description = "Helm chart for Litestream backups replicated with restic";
    homepage = "https://github.com/josh/litestream-restic-backup/tree/main/charts/litestream-restic-backup";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
