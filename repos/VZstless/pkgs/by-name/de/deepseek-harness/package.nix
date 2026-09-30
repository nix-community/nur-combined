{
  lib,
  buildNpmPackage,
  fetchurl,
  python3,
  pkg-config,
  cmake,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.2.0-rc.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-0.2.0-rc.2.tgz";
    hash = "sha256-vSeEfERc1opWWsH5HAa7vMdjnvkwcfZ4u1nF66/ziFk=";
  };

  npmDepsHash = "sha256-BBBTt7EVwE0Vpd8ABO5TlPzhfMshGLkjCrwcz6/hTe4=";

  inherit nodejs;

  nativeBuildInputs = [
    python3
    pkg-config
    cmake
  ];

  dontUseCmakeConfigure = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postFixup = ''
    # dsh needs access to Node internals (cordis-plugin-hmr, and since 0.2.0
    # dsh-app-boot's runtime interception too). The bundled native fallback
    # (node-addon-require-builtin) locates them by parsing machine code of the
    # running node binary and fails on the nix-built nodejs ("x64 sysv getter
    # is not a recognized this->field accessor"), so pass --expose-internals
    # to node explicitly. cordis-plugin-loader already prefers a direct
    # require() of internal modules when that flag is set, but dsh-app-boot
    # calls the addon unconditionally, so teach the addon's JS wrapper the
    # same shortcut.
    makeWrapper ${lib.getExe nodejs} "$out/bin/dsh" \
      --add-flags "--expose-internals" \
      --add-flags "$out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"
    substituteInPlace "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/node-addon-require-builtin/lib/index.js" \
      --replace-fail 'function requireBuiltin(moduleId) {
    return api.requireBuiltin(moduleId);
}' 'function requireBuiltin(moduleId) {
    if (process.execArgv.includes("--expose-internals")) try {
        return require(moduleId);
    } catch {}
    return api.requireBuiltin(moduleId);
}'
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "DeepSeek Harness: Everything is a Plugin";
    longDescription = ''
      DeepSeek Harness (dsh) is an open-source agent harness developed by
      DeepSeek AI. It uses an architecture where everything is a plugin,
      and is powered by Cordis.
    '';
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    downloadPage = "https://www.npmjs.com/package/@deepseek-ai/dsh";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dsh";
  };
})
