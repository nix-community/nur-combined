{
  fetchurl,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.10.0";
  src = fetchurl {
    url = "https://registry.npmjs.org/@agegr/pi-web/-/pi-web-${finalAttrs.version}.tgz";
    hash = "sha256-ywu7u2XVgrN4gWWgFR8RQ2eU/44ijictHkS8J+rbs/g=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-q0PsdHw56JjcsxBwK0TL/v2Bjxby56UX5F4OJCNfQ2Y=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;
  makeCacheWritable = true;

  npmFlags = [ "--omit=dev" ];
  dontNpmPrune = true;

  makeWrapperArgs = [
    "--set"
    "NODE_ENV"
    "production"
  ];

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    description = "Web UI for the pi coding agent";
    homepage = "https://github.com/agegr/pi-web";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "pi-web";
    platforms = lib.platforms.linux;
  };
})
