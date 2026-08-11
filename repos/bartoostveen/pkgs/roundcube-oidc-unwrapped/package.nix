{
  lib,
  php,
  fetchFromForgejo,
  nix-update-script,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "roundcube-oidc-unwrapped";
  version = "1.2.17";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "roundcube-oidc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lk4JqbsLvwnTcGydXjLaiknoYw97bQlUZExHLlGyTjM=";
  };

  vendorHash = "sha256-26eTi+ul3cO6V640Z+W3K03bwIdGtugnEgP7gk9E6CA=";
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
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
