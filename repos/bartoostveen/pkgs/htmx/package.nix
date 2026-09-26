{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "htmx";
  version = "4.0.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "bigskysoftware";
    repo = "htmx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SX2hAFDkOEyAjSxlr6Hsl1NEr46V4L+bWVyzdlRr7R0=";
  };

  npmDepsHash = "sha256-+rg0PWj1oPiCkhIhqdFVUaSJlk75GSYxsXl65qjJYXY=";

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
