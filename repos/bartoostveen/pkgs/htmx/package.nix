{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "htmx";
  version = "4.0.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "bigskysoftware";
    repo = "htmx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QGpGYoEk+bxflA3i3URrYrklw3qhvtlltO4HvE1czno=";
  };

  npmDepsHash = "sha256-hfJWj9pe1mlay4EA0D6SW7c77EOL8GB8SpSak1cC/yE=";

  installPhase = ''
    runHook preInstall
    cp dist/htmx.min.js $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Htmx - high power tools for HTML";
    homepage = "https://github.com/bigskysoftware/htmx";
    changelog = "https://github.com/bigskysoftware/htmx/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "htmx";
    platforms = lib.platforms.all;
  };
})
