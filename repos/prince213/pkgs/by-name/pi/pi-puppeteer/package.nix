{
  lib,
  buildNpmPackage,
  fetchFromGitHub,

  # buildInputs
  ffmpeg-headless,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-puppeteer";
  version = "0.3.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jcmecham";
    repo = "pi-puppeteer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CpNzkGLmv69RkKb6YWq8+uKfzjGl6fMZTiFlVHSW2YM=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-P1bo2/rKe+ebEob0pzgoUKmwy/RBZcuxa2ZhK0TyzXE=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  env.FFMPEG_BIN = lib.getExe ffmpeg-headless;

  postInstall = ''
    cp -r $out/lib/node_modules/pi-puppeteer/. $out
    rm -rf $out/lib
    ln -s $FFMPEG_BIN $out/node_modules/ffmpeg-static/ffmpeg
  '';

  meta = {
    description = "Pi extension for browser automation with Puppeteer across the Chromium family and Firefox";
    homepage = "https://github.com/jcmecham/pi-puppeteer";
    downloadPage = "https://github.com/jcmecham/pi-puppeteer/releases";
    changelog = "https://github.com/jcmecham/pi-puppeteer/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
