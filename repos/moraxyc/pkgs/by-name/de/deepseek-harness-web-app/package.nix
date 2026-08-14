{
  lib,
  buildNpmPackage,
  deepseek-harness-kernel,
  pnpmConfigHook,
  pnpm_11,
}:
buildNpmPackage (finalAttrs: {
  pname = "deepseek-harness-web-app";
  inherit (deepseek-harness-kernel) version src pnpmDeps;

  nativeBuildInputs = [ pnpm_11 ];

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    cd packages/bundle/web-app
    mkdir -p $out/lib/node_modules/@deepseek-ai/dsh-web-app
    cp -r package.json cordis.patch.yml lib $out/lib/node_modules/@deepseek-ai/dsh-web-app/
    ln -s ${deepseek-harness-kernel}/lib/deepseek-harness/node_modules \
      $out/lib/node_modules/@deepseek-ai/dsh-web-app/node_modules

    pushd ../../../apps/web
    mkdir -p $out/lib/node_modules/@deepseek-ai/dsh-web-frontend
    cp -r package.json dist $out/lib/node_modules/@deepseek-ai/dsh-web-frontend/
    popd

    runHook postInstall
  '';

  passthru = {
    dshBundles = [
      "@deepseek-ai/dsh-web-app"
      "@deepseek-ai/dsh-web-frontend"
    ];
  };

  meta = {
    description = "The dsh browser-surface bundle: the web patch layer over dsh-base";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix;
  };
})
