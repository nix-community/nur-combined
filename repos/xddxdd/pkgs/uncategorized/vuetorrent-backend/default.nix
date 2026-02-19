{
  sources,
  lib,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  inherit (sources.vuetorrent-backend) pname version src;

  npmDepsHash = "sha256-wYcI1D2a8wsjA7ZIbeNOq3mLnA6y8p6wWetPuhwHwaQ=";

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node "$out/bin/vuetorrent-backend" \
      --add-flags "$out/lib/node_modules/vuetorrent-backend/src/index.js"
  '';

  meta = {
    description = "FSimple backend service to store configuration server-side";
    homepage = "https://github.com/VueTorrent/vuetorrent-backend";
    changelog = "https://github.com/VueTorrent/vuetorrent-backend/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
