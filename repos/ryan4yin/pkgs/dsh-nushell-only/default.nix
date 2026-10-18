{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  dsh,
  mkUpdateScript,
  nushell,
}:
let
  versionData = lib.importJSON ./hashes.json;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dsh-nushell-only";
  version = versionData.version;

  src = fetchFromGitHub {
    owner = "ryan4yin";
    repo = "dsh-nushell-only";
    inherit (versionData) rev;
    hash = versionData.sourceHash;
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/node_modules
    cp -r lib/. $out/lib/
    cp package.json $out/package.json
    cp ${./cordis.patch.yml} $out/cordis.patch.yml
    substituteInPlace $out/cordis.patch.yml \
      --replace-fail '@bundle@' "$out" \
      --replace-fail '@nu@' "${nushell}"
    ln -s ${dsh}/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai $out/node_modules/@deepseek-ai

    runHook postInstall
  '';

  passthru = {
    updateScript = mkUpdateScript { name = "dsh-nushell-only"; };

    # Rendered patch used by dsh.withPlugins.
    pluginPatch = "${finalAttrs.finalPackage}/cordis.patch.yml";
    inherit nushell;
  };

  meta = {
    description = "Nushell-only shell executor, dialect guard, and teaching layer for dsh";
    homepage = "https://github.com/ryan4yin/dsh-nushell-only";
    changelog = "https://github.com/ryan4yin/dsh-nushell-only/commits/develop";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
