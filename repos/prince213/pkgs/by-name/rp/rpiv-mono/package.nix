{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.5.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cWHEfIwYqcgJHCI9iKJz73xa1ge8Vak4dvu1cWLNaBM=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-MgXxQMEJoVrFia4MV2H7PPbVLxTp5zxRx/onSSmxh3E=";

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
