{ stdenv
, lib
, fetchurl
, makeWrapper
, jdk17
, udev
, xorg
}:

stdenv.mkDerivation rec {
  pname = "atlauncher";
  version = "3.4.35.4";

  src = fetchurl {
    url = "https://github.com/ATLauncher/ATLauncher/releases/download/v${version}/ATLauncher-${version}.jar";
    hash = "sha256-M8ygN70yizJM6VEffBh/lH/DneKAzQ5UFzc3g51dja0=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/java
    cp $src $out/share/java/ATLauncher.jar
    makeWrapper ${jdk17}/bin/java $out/bin/atlauncher \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ xorg.libXxf86vm udev ]}" \
      --add-flags "-jar $out/share/java/ATLauncher.jar" \
      --add-flags "--working-dir \''${XDG_DATA_HOME:-\$HOME/.local/share}/ATLauncher" \
      --add-flags "--no-launcher-update"
  '';

  meta = {
    description = "Minecraft launcher";
    longDescription = ''
      ATLauncher is a Launcher for Minecraft which integrates multiple different
      ModPacks to allow you to download and install ModPacks easily and quickly.
    '';
    sourceProvenance = [
      (lib.sourceTypes.binaryBytecode or { shortName = "binaryBytecode"; isSource = false; })
    ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    homepage = "https://atlauncher.com/";
  };
}
