{
  fetchurl,
  lib,
  buildNpmPackage,
  nodejs,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "waline";
  version = "1.43.4";
  src = fetchurl {
    url = "https://registry.npmjs.org/@waline/vercel/-/vercel-${finalAttrs.version}.tgz";
    hash = "sha256-1xm2WSF40K1vk6gD3vS5PLsn+oErZ0LcMvcyq+14inw=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-8W0iGEp9tWrgCmtp/5NQB+zMTP28bPRaLJd0W1RGopU=";

  patches = [ ./runtime-path.patch ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/waline \
      --set NODE_ENV production \
      --add-flags "$out/lib/node_modules/@waline/vercel/vanilla.js"
  '';

  meta = {
    description = "Server for the Waline comment system";
    homepage = "https://github.com/walinejs/waline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "waline";
    platforms = lib.platforms.linux;
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };
})
