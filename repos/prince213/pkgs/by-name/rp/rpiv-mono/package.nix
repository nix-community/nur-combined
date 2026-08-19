{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.6.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z/q31p5p3JTvuvWbHnCetc/atk3te68gG9+z8/Nq1Zc=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-8FdaHw2en1rFAKf3B8MlCV6jBgrkjlooIJGxrGPdgtc=";

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/rpiv-mono/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extensions";
    homepage = "https://github.com/juicesharp/rpiv-mono";
    downloadPage = "https://github.com/juicesharp/rpiv-mono/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
