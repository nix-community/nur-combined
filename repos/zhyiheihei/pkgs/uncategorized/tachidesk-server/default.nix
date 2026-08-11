{
  lib,
  stdenv,
  makeWrapper,
  jre,
  sources,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tachidesk-server";
  inherit (sources.tachidesk-server) version src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D -m 0644 ${finalAttrs.src} $out/share/suwayomi/Suwayomi-Server.jar
    makeWrapper ${lib.getExe jre} $out/bin/tachidesk-server \
      --add-flags "-jar $out/share/suwayomi/Suwayomi-Server.jar"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/Suwayomi/Suwayomi-Server/releases/tag/v${finalAttrs.version}";
    description = "Self-hosted manga reader and aggregator server";
    homepage = "https://github.com/Suwayomi/Suwayomi-Server";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "tachidesk-server";
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
})
