{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-simplify";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "MattDevy";
    repo = "pi-extensions";
    tag = "pi-simplify-v${finalAttrs.version}";
    hash = "sha256-bFpHtHBpBop56ylNGwwNsy6090vcOz6aMUAn3i6SE4A=";
  };

  npmDepsHash = "sha256-i5G7SD90ycuIHpbcB6osiC0NgwuRn0mozeML59nEpNQ=";

  buildPhase = ''
    npm run build --workspace=pi-simplify
  '';

  # package.json sets `dist/...` as the entry point, so we need to install that.
  # this also installs all the `src/...`: not necessary, but oh well.
  installPhase = ''
    runHook preInstall
    cp -R packages/pi-simplify $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A Pi extension that reviews recently changed code for clarity, consistency, and maintainability improvements.";
    homepage = "https://github.com/MattDevy/pi-extensions/tree/main/packages/pi-simplify";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
