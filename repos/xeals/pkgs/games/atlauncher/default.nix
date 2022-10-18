{ stdenv
, lib
, fetchurl
, makeWrapper
, jre
, udev
}:

stdenv.mkDerivation rec {
  pname = "atlauncher";
  version = "3.4.20.2";

  src = fetchurl {
    url = "https://github.com/ATLauncher/ATLauncher/releases/download/v${version}/ATLauncher-${version}.jar";
    hash = "sha256-YnCDs67BVhJ5rwY6jTbfgHKPbavtmcIMd16AWMBUDgk=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/java
    cp $src $out/share/java/ATLauncher.jar
    makeWrapper ${jre}/bin/java $out/bin/atlauncher \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ udev ]}" \
      --add-flags "-jar $out/share/java/ATLauncher.jar" \
      --add-flags "--working-dir \''${XDG_DATA_HOME:-\$HOME/.local/share}/ATLauncher"
  '';

  meta = with lib; {
    description = "Minecraft launcher";
    longDescription = ''
      ATLauncher is a Launcher for Minecraft which integrates multiple different
      ModPacks to allow you to download and install ModPacks easily and quickly.
    '';
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl3Only;
    platforms = platforms.all;
    homepage = "https://atlauncher.com/";
  };
}
