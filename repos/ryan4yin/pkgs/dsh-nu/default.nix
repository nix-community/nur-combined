{
  lib,
  stdenvNoCC,
  fetchurl,
  dsh,
  mkUpdateScript,
  nushell,
}:
let
  versionData = lib.importJSON ./hashes.json;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dsh-nu";
  version = versionData.version;

  src = fetchurl {
    url = "https://github.com/ryan4yin/dsh-nu/releases/download/v${versionData.version}/dsh-nu-${versionData.version}.tgz";
    hash = versionData.sourceHash;
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir source
    tar -xzf $src -C source --strip-components=1
    cd source
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/node_modules
    cp -r dist examples package.json cordis.patch.yml README.md LICENSE $out/

    # dsh.withPlugins applies this patch as a file path, so the bundle's
    # package-name imports become absolute paths. nuPath is fixed at build
    # time because the wrapper does not inherit a Nushell PATH entry.
    substituteInPlace $out/cordis.patch.yml \
      --replace-fail 'dsh-nu/executor' "$out/dist/executor.js" \
      --replace-fail 'dsh-nu/teaching' "$out/dist/teaching.js"
    sed -i "s|nuPath:.*|nuPath: ${nushell}/bin/nu|" $out/cordis.patch.yml

    ln -s ${dsh}/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai $out/node_modules/@deepseek-ai

    runHook postInstall
  '';

  passthru = {
    updateScript = mkUpdateScript { name = "dsh-nu"; };

    # Rendered patch used by dsh.withPlugins.
    pluginPatch = "${finalAttrs.finalPackage}/cordis.patch.yml";
    inherit nushell;
  };

  meta = {
    description = "Nushell-only shell executor, dialect guard, and teaching layer for dsh";
    homepage = "https://github.com/ryan4yin/dsh-nu";
    changelog = "https://github.com/ryan4yin/dsh-nu/releases";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
