{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "vuetorrent-backend";
  version = "2.7.3";
  src = fetchFromGitHub {
    owner = "VueTorrent";
    repo = "vuetorrent-backend";
    tag = "v2.7.3";
    hash = "sha256-/zsv18BmpjhJ1UrXCtnynzvULWI8YqzhcUWNaCo84Ls=";
  };
  npmDepsHash = "sha256-TaXOQnyZizPA8/Rr5pBNMIQl5zIiPQJs54mFPT/18o8=";

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node "$out/bin/vuetorrent-backend" \
      --add-flags "$out/lib/node_modules/vuetorrent-backend/src/index.js"
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Simple backend service to store configuration server-side";
    homepage = "https://github.com/VueTorrent/vuetorrent-backend";
    changelog = "https://github.com/VueTorrent/vuetorrent-backend/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
