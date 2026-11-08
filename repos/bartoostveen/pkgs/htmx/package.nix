{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "htmx";
  version = "4.0.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "bigskysoftware";
    repo = "htmx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CtDnTsXax/mSkd/3wvU36uUz/8WKwus1xlgAqc2oX8o=";
  };

  npmDepsHash = "sha256-ygmrKcEja45bO45mAUFIK7mB6+nM/IoGUarLTEuW+r8=";

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
