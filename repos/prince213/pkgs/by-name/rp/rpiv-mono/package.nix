{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.13.5";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ihb+7moyGRqk7N3O+afOpPvKJJfUPzEDVRM8mBkGIKk=";
  };

  patches = [ ./package-json.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-0Kv/kiLjkM9S1GVDgn773Ixs1TV6skXA6wzgqd6l/JY=";

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
