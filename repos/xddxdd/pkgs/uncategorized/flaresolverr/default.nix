{ lib
, sources
, buildNpmPackage
, makeWrapper
, firefox
, ...
}:

buildNpmPackage {
  inherit (sources.flaresolverr) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  npmDepsHash = "sha256-9DzlYOoSrdKEAqDmjYtKaIbw7SoOH5Sgs2pvfseJHIo=";

  NODE_OPTIONS = "--openssl-legacy-provider";

  # Skip download firefox
  postPatch = ''
    export PUPPETEER_PRODUCT=firefox
    export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
    export PUPPETEER_EXECUTABLE_PATH=${firefox}/bin/firefox
  '';

  postFixup = ''
    wrapProgram "$out/bin/flaresolverr" \
      --set-default PUPPETEER_PRODUCT "firefox" \
      --set-default PUPPETEER_EXECUTABLE_PATH "${firefox}/bin/firefox"
  '';

  meta = with lib; {
    description = "Proxy server to bypass Cloudflare protection";
    homepage = "https://github.com/FlareSolverr/FlareSolverr";
    license = licenses.mit;
  };
}
