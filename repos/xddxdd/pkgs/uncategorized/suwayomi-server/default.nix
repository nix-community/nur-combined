{
  stdenvNoCC,
  lib,
  sources,
  unzip,
  jre_headless,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.suwayomi-server) pname version src;

  dontUnpack = true;

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/opt/suwayomi-server.jar

    mkdir -p $out/bin
    makeWrapper ${jre_headless}/bin/java $out/bin/suwayomi-server \
      --add-flags "-jar" \
      --add-flags "$out/opt/suwayomi-server.jar"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rewrite of Tachiyomi for the Desktop";
    homepage = "https://github.com/Suwayomi/Suwayomi-Server";
    license = lib.licenses.mpl20;
    mainProgram = "suwayomi-server";
  };
})
