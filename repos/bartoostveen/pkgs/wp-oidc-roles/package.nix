{
  lib,
  php,
  fetchFromForgejo,
  nix-update-script,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "oidc-wp-roles";
  version = "1.0.3";

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "oidc-wp-roles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Ka/8se1Ga7a65tGKTuvq3IOcGOFlhWwc90a1VPPXmk=";
  };

  vendorHash = "sha256-OaMAStgzzHwxrSzPOhI5H7J0GXsBU6nIBNqbJCWTtUY=";

  installPhase = ''
    runHook preInstall
    cp -R ./. $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--url=\"https://git.bartoostveen.nl/bart/oidc-wp-roles.git\"" ];
  };

  meta = {
    description = "Extension to oidc-wp/openid-connect-generic plugin that maps 3rd party service data as WordPress user data. Optionally restrict access to content";
    homepage = "https://git.bartoostveen.nl/bart/oidc-wp-roles";
    changelog = "https://git.bartoostveen.nl/bart/oidc-wp-roles/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ bartoostveen ];
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
  };
})
