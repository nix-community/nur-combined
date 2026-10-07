{
  fetchurl,
  lib,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "waline";
  version = "1.43.4";
  src = fetchurl {
    url = "https://registry.npmjs.org/@waline/vercel/-/vercel-${finalAttrs.version}.tgz";
    hash = "sha256-1xm2WSF40K1vk6gD3vS5PLsn+oErZ0LcMvcyq+14inw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  sourceRoot = "package";

  npmDepsHash = "sha256-0xVsKuLKl8zANbIv0czIfB+A1x7+V9yE11V0pm9KARY=";

  patches = [ ./runtime-path.patch ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    cp -r node_modules/@waline/core "$NIX_BUILD_TOP/waline-core"
    sed -i '/"@waline\/core":/d' package.json
  '';

  npmFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/waline \
      --set NODE_ENV production \
      --add-flags "$out/lib/node_modules/@waline/vercel/vanilla.js"
    mkdir -p $out/lib/node_modules/@waline/vercel/node_modules/@waline
    cp -r "$NIX_BUILD_TOP/waline-core" $out/lib/node_modules/@waline/vercel/node_modules/@waline/core
  '';

  meta = {
    description = "Server for the Waline comment system";
    homepage = "https://github.com/walinejs/waline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "waline";
    platforms = lib.platforms.linux;
  };

  passthru.updateScript = [ (toString ./update.sh) ];
})
