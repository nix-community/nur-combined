{
  fetchurl,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.9.1";
  src = fetchurl {
    url = "https://registry.npmjs.org/@agegr/pi-web/-/pi-web-${finalAttrs.version}.tgz";
    hash = "sha256-5AY/SswQwJjZGi8zmVOLWpOPmXVZU4SonHWtYeK+LNc=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-ZUI4IMS6loVQB8YPeUB1N/6IP2XbY4V6dvBHm8V4EcU=";

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
