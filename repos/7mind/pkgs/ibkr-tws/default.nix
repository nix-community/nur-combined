{ lib
, stdenv
, makeWrapper
, jdk17
, fetchurl
, glib
, gtk3
, pango
, cairo
, libX11
, libGL
, chromium
, xorg
, cups
, mesa
, alsa-lib
, libxkbcommon
, libdrm
, nspr
, nss
, atk
, dbus
, expat
, at-spi2-atk
, at-spi2-core
,
}:

let
  version = "10.19.2h";
  src = fetchurl {
    urls = [
      "https://download2.interactivebrokers.com/installers/tws/stable-standalone/tws-stable-standalone-linux-x64.sh"
    ];
    sha256 = "sha256-AaaivIBV+8LeelVwDDTFOZS+pda1K/XtiDHEHAp7mb4=";
  };
  jre = jdk17.override { enableJavaFX = true; };
  dynamicLibraries = [
    glib
    gtk3
    pango
    cairo
    libX11
    libGL
    chromium
    xorg.libXext
    xorg.libxcb
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXrandr
    xorg.libXdamage
    cups
    mesa
    alsa-lib
    libxkbcommon
    libdrm
    nspr
    nss
    atk
    dbus
    expat
    at-spi2-atk
    at-spi2-core
  ];
in
stdenv.mkDerivation {
  pname = "ibkr-tws";
  inherit version src;
  nativeBuildInputs = [ makeWrapper ];
  #buildInputs = [ glib gtk3 pango cairo libX11 libGL chromium ];
  phases = [ "installPhase" ];

  installPhase = ''
    export app_java_home=${jre}

    cp $src installer
    chmod +x installer

    # a hack to allow the installer run on JDK>8
    sed -i 's/-Djava.ext.dirs/-Djava.ext.xxxx/' installer

    ./installer -q -dir $out

    sed -i 's/\\''${installer:jtsConfigDir}/''${HOME}\/.config\/jts/g' $out/tws
    sed -i '/jtsConfigDir/d' $out/.install4j/response.varfile

    mv $out/*.desktop $out/tws.desktop
    substituteInPlace $out/tws.desktop \
        --replace "Exec=\"$out/tws\"" "Exec=$out/bin/tws"

    install -Dt $out/share/applications $out/tws.desktop

    makeWrapper $out/tws $out/bin/tws \
      --set app_java_home ${jre} \
      --set _JAVA_OPTIONS "" \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath dynamicLibraries}
  '';

  meta = with lib; {
    homepage = "https://www.interactivebrokers.com/en/trading/tws.php";
    description = "InteractiveBrokers Trader Workstation (TWS)";
    license = licenses.unfree;
    maintainers = with maintainers; [ pshirshov ];
    platforms = platforms.all;
  };
}
