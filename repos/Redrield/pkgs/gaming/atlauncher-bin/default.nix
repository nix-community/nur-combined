{ stdenv, fetchurl, lib, makeWrapper, libglvnd, libpulseaudio, udev, xorg, flite, gamemode, jre }:
stdenv.mkDerivation rec {
  pname = "atlauncher";
  version = "3.4.38.2";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-${version}.jar";
    hash = "sha256-IKaHQwyT8DcLgwbanazkqIMUVGTsy4lqCwr5bvfHWGQ=";
  };

  unpackPhase = ":";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = 
    let runtimeLibraries = 
      [ 
        libglvnd
        libpulseaudio
        udev
        xorg.libX11
        xorg.libXcursor
        xorg.libXxf86vm
        gamemode.lib
        flite
      ];
    in
    ''
    mkdir -p $out/bin
    mkdir -p $out/share/java
    cp $src $out/share/java/ATLauncher.jar


    makeWrapper ${lib.getExe jre} $out/bin/atlauncher \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
      --add-flags "-jar $out/share/java/ATLauncher.jar" \
      --add-flags "--working-dir \"\''${XDG_DATA_HOME:-\$HOME/.local/share}/ATLauncher\"" \
      --add-flags "--no-launcher-update"

    install -Dm444 ${./atlauncher.desktop} -t $out/share/applications
    install -Dm444 ${./atlauncher.metainfo.xml} -t $out/share/metainfo
    install -Dm444 ${./atlauncher.png} -t $out/share/pixmaps
    install -Dm444 ${./atlauncher.svg} -t $out/share/icons/hicolor/scalable/apps
    '';
}
