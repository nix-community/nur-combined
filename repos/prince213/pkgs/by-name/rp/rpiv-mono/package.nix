{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
}:

buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.11.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lXSj7i0bKuOKdajoJqLukCqNMi6398IxRFgFbXHgUUA=";
  };

  patches = [
    # https://github.com/juicesharp/rpiv-mono/pull/278
    (fetchpatch2 {
      url = "https://github.com/BasamAhmed640/rpiv-mono/commit/e325a8b8269af69f63799c7fc5d2b34be88dfb08.patch?full_index=1";
      excludes = [
        "package-lock.json"
        "packages/rpiv-workflow/CHANGELOG.md"
      ];
      hash = "sha256-zU9eJrp70OURBRV6AHPm2TrxHT47nsqIKUMsV4Wit9A=";
    })

    ./package-lock.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-l1OC1Klv06K2O8S1SJSiErTBthmG0UllBcFoR7REO6E=";

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
