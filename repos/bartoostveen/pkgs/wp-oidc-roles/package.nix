{
  lib,
  php,
  fetchFromGitHub,
  nix-update-script,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "wp-oidc-roles";
  version = "1.0.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "oidc-wp";
    repo = "oidc-wp-roles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VMEx6LtcG//p3tXI/T8JLRd+ctqkbmfLN69VunSiH/s=";
  };

  vendorHash = "sha256-1sLJvhzSC/0DamHB9o1j3+HzZSLntMQG34RmmcJD8+k=";
  composerStrictValidation = false;

  installPhase = ''
    runHook preInstall
    cp -R ./. $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open ID Connect - WordPress Roles";
    homepage = "https://github.com/oidc-wp/oidc-wp-roles";
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
