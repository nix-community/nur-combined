{
  lib,
  php,
  fetchFromForgejo,
  nix-update-script,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "roundcube-oidc-unwrapped";
  version = "1.3.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "roundcube-oidc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6SKWlfWasS5tbVL27/SePf64b0asn56+qd7JrgjNERE=";
  };

  vendorHash = "sha256-LXLnrzVJ72X1Fkck3OjPj9215POVft4xJdQWHyP/9bQ=";
  composerStrictValidation = false;

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
