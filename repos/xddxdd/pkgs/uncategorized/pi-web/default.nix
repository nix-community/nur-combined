{
  fetchurl,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.9.2";
  src = fetchurl {
    url = "https://registry.npmjs.org/@agegr/pi-web/-/pi-web-${finalAttrs.version}.tgz";
    hash = "sha256-95e21yZpQPY4LgaSSxhR+mtlA5hwjwdhpl3FfKGzZZ0=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-ZTkp+PEkblkbSmZZue/cOLWxo8JF6YFz57bW9b//NaI=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;
  makeCacheWritable = true;

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
