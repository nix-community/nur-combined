{
  fetchurl,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.8.11";
  src = fetchurl {
    url = "https://registry.npmjs.org/@agegr/pi-web/-/pi-web-${finalAttrs.version}.tgz";
    hash = "sha256-abqj1NyTKJJKiuA9Qx/z6l4KcH4cmutHCM8x27B8uDQ=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-IbkiVrfRaKXWW9MK1wxLG0tuBRpftn2dw88WTEDj2TY=";

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
