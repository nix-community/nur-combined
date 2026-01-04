{
  sources,
  stdenvNoCC,
  lib,
  jre_headless,
  makeWrapper,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.jproxy) pname version src;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/

    makeWrapper ${lib.getExe jre_headless} $out/bin/jproxy \
      --add-flags "-Xms512m" \
      --add-flags "-Xmx512m" \
      --add-flags "-Dfile.encoding=utf-8" \
      --add-flags "-jar" \
      --add-flags "$out/opt/jproxy.jar"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Proxy between Sonarr / Radarr and Jackett / Prowlarr, mainly used to optimize search and improve recognition rate";
    homepage = "https://github.com/LuckyPuppy514/jproxy";
    license = lib.licenses.mit;
    mainProgram = "jproxy";
  };
})
