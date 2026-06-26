{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  pname = "summarize";
  version = "0.20.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@steipete/summarize/-/summarize-${finalAttrs.version}.tgz";
    hash = "sha256-obUZYElBurbCzZywyIC+CFeGPBPvl39vC/LDSlKUr54=";
  };

  npmDepsHash = "sha256-U2o+rUl3gEV7Tktbtp3PTuMA5RhWlAwY3VSgEylbnMU=";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "Link → clean text → summary.";
    homepage = "https://github.com/steipete/summarize";
    license = lib.licenses.mit;
    mainProgram = "summarize";
  };
})
