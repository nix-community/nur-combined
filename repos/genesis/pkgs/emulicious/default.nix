{ lib, stdenv, jre, makeWrapper, fetchzip, adoptopenjdk-jre-bin }:

stdenv.mkDerivation rec {
  version = "2024-05-31";
  pname = "emulicious";

  src = fetchzip {
    url = "https://emulicious.net/emulicious/downloads/${pname}-${version}.zip";
    sha256 = "sha256-VsEAzqB97puSvPg8CxZAdr9bP2K7jSy02haguWsP7Z0=";
    stripRoot=false;
  };

  nativeBuildInputs = [ makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall
    install -D $src/Emulicious.jar $out/lib/Emulicious.jar
    makeWrapper ${adoptopenjdk-jre-bin}/bin/java $out/bin/emulicious --add-flags "-jar $out/lib/Emulicious.jar"
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://emulicious.net/";
    description = "Game Boy, Game Boy Color, Master System, Game Gear and MSX emulator";
    mainProgram = "emulicious";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ genesis ];
    platforms = [ "x86_64-linux" ];
  };
}
