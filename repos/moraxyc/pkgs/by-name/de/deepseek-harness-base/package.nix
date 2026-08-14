{
  lib,
  stdenv,
  bubblewrap,
  buildNpmPackage,
  deepseek-harness-kernel,
  pnpmConfigHook,
  pnpm_11,
  ripgrep,
}:

buildNpmPackage (finalAttrs: {
  pname = "deepseek-harness-base";
  inherit (deepseek-harness-kernel) version src pnpmDeps;

  nativeBuildInputs = [ pnpm_11 ];

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;
  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    cd packages/bundle/base
    mkdir -p $out/lib/node_modules/@deepseek-ai/dsh-base
    cp -r package.json cordis.patch.yml lib $out/lib/node_modules/@deepseek-ai/dsh-base/
    ln -s ${deepseek-harness-kernel}/lib/deepseek-harness/node_modules \
      $out/lib/node_modules/@deepseek-ai/dsh-base/node_modules

    runHook postInstall
  '';

  passthru = {
    dshBundles = [ "@deepseek-ai/dsh-base" ];
    runtimeDeps = [ ripgrep ] ++ lib.optionals stdenv.hostPlatform.isLinux [ bubblewrap ];
  };

  meta = {
    description = "The shared dsh core as a profile bundle: every profile's first patch layer";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix;
  };
})
