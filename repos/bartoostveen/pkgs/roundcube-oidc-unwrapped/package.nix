{
  lib,
  php,
  fetchFromForgejo,
  nix-update-script,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "roundcube-oidc-unwrapped";
  version = "1.3.6";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "roundcube-oidc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7BhXh2qTnhLob+Wd57wXgESWSbc38l7jYXat1dzQoxY=";
  };

  vendorHash = "sha256-bRPmwZS6orMjsnW/yklcWUY2mA03gDYml9Iu4X6aRI0=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/plugins/roundcube_oidc
    cp -R * $out/plugins/roundcube_oidc/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenID Connect authentication plugin for Roundcube";
    homepage = "https://git.bartoostveen.nl/bart/roundcube-oidc";
    license = lib.licenses.mit;
    changelog = "https://git.bartoostveen.nl/bart/roundcube-oidc/src/tag/${finalAttrs.src.tag}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
