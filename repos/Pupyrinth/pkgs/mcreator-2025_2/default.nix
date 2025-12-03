{
  lib,
  stdenv,
  gobject-introspection,
  gdk-pixbuf,
  libGL,
  makeWrapper,
  jdk,
  cairo,
  glib,
  unzip,
  pkg-config,
  pango,
  gtk3,
  at-spi2-atk,
  xorg,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "mcreator";
  version = "2025.2";

  src = fetchurl {
    url = "https://github.com/MCreator/MCreator/releases/download/2025.2.28610/MCreator.2025.2.Linux.64bit.tar.gz";
    hash = "sha256-Jt2IDSUqr9mro+6bpdp4kqG6jTQ6aT0q9RQNLmeGj+I=";
  };

  nativeBuildInputs = [
    jdk
    cairo
    glib
    makeWrapper
    pkg-config
    pango
    gtk3
    at-spi2-atk
    xorg.libXtst
    xorg.libX11
    gobject-introspection
    gdk-pixbuf
    unzip
    libGL
    xorg.libXxf86vm
  ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -dm 0755 $out/share/mcreator
    rm -r jdk
    rm mcreator.sh
    touch mcreator.sh
    chmod +x mcreator.sh

    cp -rf * $out/share/mcreator/

    install -dm 0755 $out/share/icons/hicolor/64x64
    cp $out/share/mcreator/icon.png $out/share/icons/hicolor/64x64/mcreator.png

    cat > $out/share/mcreator/mcreator.sh <<EOF
    export CLASSPATH="$out/share/mcreator/lib/mcreator.jar:$out/share/mcreator/lib/*"
    cd $out/share/mcreator
    ${jdk}/bin/java --add-opens=java.base/java.lang=ALL-UNNAMED net.mcreator.Launcher "\$1"
    EOF

    chmod +x $out/share/mcreator/mcreator.sh

    install -dm 0755 $out/share/applications

    cat > $out/share/applications/mcreator.desktop <<EOF
    [Desktop Entry]
    Exec=$out/bin/mcreator
    Type=Application
    Terminal=false
    Name=MCreator 2025.2
    Categories=Development;IDE;
    Comment=MCreator IDE for Minecraft mods
    Icon=$out/share/icons/hicolor/64x64/mcreator.png
    EOF

    chmod +x $out/share/applications/mcreator.desktop

    runHook postInstall
  '';

  preFixup = ''
     makeWrapper $out/share/mcreator/mcreator.sh $out/bin/mcreator --prefix PATH : ${lib.makeBinPath [ jdk ]} --set JAVA_HOME ${jdk}/lib/openjdk --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ cairo glib pkg-config pango gtk3 at-spi2-atk xorg.libXtst xorg.libX11 gobject-introspection gdk-pixbuf libGL xorg.libXxf86vm ]}
  '';

  meta = {
    description = "MCreator is an open-source software used to make Minecraft Java Edition mods, Minecraft Bedrock Edition Add-Ons, resource packs, and data packs using an intuitive easy-to-learn interface or with an integrated code editor. It is used worldwide by Minecraft players, aspiring mod developers, for education, online classes, and STEM workshops. ";
    homepage = "https://github.com/MCreator/MCreator";
    license = lib.licenses.gpl3;
    # maintainers = with lib.maintainers; [];
    mainProgram = "mocu-xcursor";
    platforms = lib.platforms.all;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
