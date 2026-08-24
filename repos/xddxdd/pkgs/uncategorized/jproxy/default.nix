{
  fetchurl,
  stdenv,
  lib,
  jre_headless,
  makeWrapper,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jproxy";
  version = "3.4.1";
  src = fetchurl {
    url = "https://github.com/LuckyPuppy514/jproxy/releases/download/v3.4.1/windows-v3.4.1.zip";
    hash = "sha256-DPYHHIc6bH8X3tUcEd4xE0W/Q5BBBofdEtM9x3T+0vk=";
  };
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
