# Copied from https://github.com/CrackTC/nur-packages
{ lib
, stdenvNoCC
, fetchzip

, jdk
, libjportaudio
, makeWrapper
, openal
, writeShellScript
, xrandr
}:

let
  pname = "beatoraja-modernchic";
  version = "0.8.8";
  fullName = "beatoraja${version}-modernchic";
  beatoJDK = jdk.override { enableJavaFX = true; };
  startupScript = writeShellScript "beatoraja.sh" ''
    export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
    dataDir="''${XDG_DATA_HOME:-$HOME/.local/share}/beatoraja"
    if [ ! -d "$dataDir" ]; then
      mkdir -p "$dataDir"
      cp -r $out/opt/beatoraja/* "$dataDir"
      find "$dataDir" -type f -exec chmod 644 {} \;
      find "$dataDir" -type d -exec chmod 755 {} \;
    fi
    cd "''${XDG_DATA_HOME:-$HOME/.local/share}/beatoraja"
    exec ${beatoJDK}/bin/java -Xms1g -Xmx4g -jar $out/opt/beatoraja/beatoraja.jar $@
  '';
  src = fetchzip {
    url = "https://mocha-repository.info/download/${fullName}.zip";
    hash = "sha256-TujfJ7hgjEKs5NbGvwo3/nkbJFvcZ4mefgkdp6oQHw4=";
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  buildInputs = [ openal libjportaudio xrandr ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    rm beatoraja-config.*
    rm *.dll

    mkdir -p $out/opt/beatoraja $out/bin
    ln -s ${startupScript} $out/bin/beatoraja
    mv * $out/opt/beatoraja/

    wrapProgram $out/bin/beatoraja \
      --prefix PATH : "${xrandr}/bin" \
      --set out $out \
      --prefix LD_LIBRARY_PATH : "${openal}/lib" \
      --prefix LD_LIBRARY_PATH : "${libjportaudio}/lib" \
      --prefix LD_PRELOAD : "${openal}/lib/libopenal.so" \
      --prefix LD_PRELOAD : "${libjportaudio}/lib/libjportaudio.so"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cross-platform rhythm game based on Java and libGDX.";
    homepage = "https://github.com/exch-bms2/beatoraja";
    license = [ licenses.gpl3Only "unknown" ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "beatoraja";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
}
