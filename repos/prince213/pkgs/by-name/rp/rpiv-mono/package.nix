{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.13.7";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LX3Ghhlq7cyv386NxhagKLwS8ZnFd1EpsZghVUVNmBc=";
  };

  patches = [ ./package-json.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-+b2Lt5QjrU8pWdAnlL9+Y97hOiNHhK+tkpqOogYnAhI=";

  npmPruneFlags = [ "--omit=peer" ];

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
