{
  lib,
  buildNpmPackage,
  deepseek-harness-kernel,
  pnpmConfigHook,
  pnpm_11,
}:
buildNpmPackage (finalAttrs: {
  pname = "deepseek-harness-headless";
  inherit (deepseek-harness-kernel) version src pnpmDeps;

  nativeBuildInputs = [ pnpm_11 ];

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    cd packages/bundle/headless
    mkdir -p $out/lib/node_modules/@deepseek-ai/dsh-headless
    cp -r package.json cordis.patch.yml lib $out/lib/node_modules/@deepseek-ai/dsh-headless/
    ln -s ${deepseek-harness-kernel}/lib/deepseek-harness/node_modules \
      $out/lib/node_modules/@deepseek-ai/dsh-headless/node_modules

    runHook postInstall
  '';

  passthru = {
    dshBundles = [ "@deepseek-ai/dsh-headless" ];
  };

  meta = {
    description = "The dsh one-shot bundle: a direct core Agent/Session runner over dsh-base";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix;
  };
})
