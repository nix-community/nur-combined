{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  playwright-driver,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "playwright-scrape";
  version = "0.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  dontUnpack = true;

  buildInputs = [ (python3.withPackages (ps: [ ps.playwright ])) ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${./main.py} $out/bin/playwright-scrape
    wrapProgram $out/bin/playwright-scrape --set-default PLAYWRIGHT_BROWSERS_PATH ${playwright-driver.browsers}

    runHook postInstall
  '';

  meta = {
    description = "A simple web scraper using Playwright";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.all;
    mainProgram = "playwright-scrape";
  };
})
