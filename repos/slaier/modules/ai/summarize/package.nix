{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage (finalAttrs: {
  pname = "summarize";
  version = "0.21.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@steipete/summarize/-/summarize-${finalAttrs.version}.tgz";
    hash = "sha256-6LPgbDADPk9cptWpU9pE1hlQ2/52DVr+mEXQQIFB76s=";
  };

  npmDepsHash = "sha256-/QR4duLpuYpqMVe12MQVSZ7TtKwQ5ymHZCdzTCvYW1E=";

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
