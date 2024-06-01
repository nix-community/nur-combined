{ lib, stdenv, jre, makeWrapper, requireFile }:

stdenv.mkDerivation rec {
  version = "2024-05-31";
  pname = "emulicious";

  # src = fetchzip {
  #   name = "${pname}-${version}.zip";
  #   url = "https://emulicious.net/download/emulicious/?wpdmdl=205";
  #   sha256 = "082jxhrd1zrxhkq6axww3nldrilf9hqfnn0i2syg4dqfl8jdmlg7";
  # };

  src = requireFile {
    name = "emulicious.zip";
    message = ''
      This nix expression requires that emulicious.zip is
      already part of the store. Find the file on ${meta.homepage}
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "082jxhrd1zrxhkq6axww3nldrilf9hqfnn0i2syg4dqfl8jdmlg7";
  };

  nativeBuildInputs = [ makeWrapper ];

# see https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=emulicious-bin

  # installPhase = ''
  #   runHook preInstall

  #   mkdir -p $out/share/java
  #   mv $(ls */*.jar) $out/share/java

  #   makeWrapper $out/share/java/frostwire $out/bin/frostwire \
  #     --prefix PATH : ${jre}/bin \
  #     --prefix LD_LIBRARY_PATH : $out/share/java \
  #     --set JAVA_HOME "${jre}"

  #   substituteInPlace $out/share/java/frostwire \
  #     --replace "export JAVA_PROGRAM_DIR=/usr/lib/frostwire/jre/bin" \
  #       "export JAVA_PROGRAM_DIR=${jre}/bin/"

  #   substituteInPlace $out/share/java/frostwire.desktop \
  #     --replace "Exec=/usr/bin/frostwire %U" "Exec=${placeholder "out"}/bin/frostwire %U"

  #   runHook postInstall
  # '';

  meta = with lib; {
    broken = true;
    homepage = "https://emulicious.net/";
    description = "Game Boy, Game Boy Color, Master System, Game Gear and MSX emulator";
    mainProgram = "emulicious";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ genesis ];
    platforms = [ "x86_64-linux" ];
  };
}
