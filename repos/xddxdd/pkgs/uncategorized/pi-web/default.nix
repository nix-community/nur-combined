{
  fetchurl,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.9.3";
  src = fetchurl {
    url = "https://registry.npmjs.org/@agegr/pi-web/-/pi-web-${finalAttrs.version}.tgz";
    hash = "sha256-5nbI+CIPT0iY8pQ1J4lrqXdEt4izvlyz0UFZDmkEFkI=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-+GV3ww/KB6vzLAH9xt7GI+0ioz4/86oH2nUQKYjW6/o=";

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
