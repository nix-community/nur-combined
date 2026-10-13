{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "rpiv-mono";
  version = "2.13.8";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "juicesharp";
    repo = "rpiv-mono";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s8xMQx1fqInIZjWWroYqEsPWmR8jjrzDWXP+jiL9pyY=";
  };

  patches = [ ./package-json.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-2m9gYKu0b3TqoU8BQUZdjhKSMtJv1ERt5DLanmfAHt4=";

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
