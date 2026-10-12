{ lib
, stdenv
, fetchurl
, makeDesktopItem
, makeWrapper
, autoPatchelfHook
, coreutils
, git
, glibcLocales
, gnugrep
, which
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, e2fsprogs
, expat
, fontconfig
, freetype
, glib
, gtk3
, libGL
, libdrm
, libgbm
, libnotify
, libsecret
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxkbcommon
, libxrandr
, libxrender
, libxtst
, libxxf86vm
, nspr
, nss
, pango
, udev
, zlib
}:

let
  pname = "openide";
  version = "262.10968.63.1";

  sources = {
    x86_64-linux = {
      url = "https://download.openide.ru/${version}/openIDE-${version}.tar.gz";
      hash = "sha256-7SH5EqUE3j6t2IC8ECgzRrzj+Ala7DlFH/DAvS3yZ34=";
    };
    aarch64-linux = {
      url = "https://download.openide.ru/${version}/openIDE-${version}-aarch64.tar.gz";
      hash = "sha256-TNtnJvvKerFrYtd6kxq1SLY7uENeG1Bgu3wyX5xnH9Q=";
    };
  };

  src = sources.${stdenv.hostPlatform.system}
    or (throw "openide: unsupported system ${stdenv.hostPlatform.system}");

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} %F";
    icon = pname;
    comment = "Java IDE based on IntelliJ IDEA";
    desktopName = "OpenIDE";
    genericName = "Java IDE";
    categories = [ "Development" "IDE" ];
    startupWMClass = "openide";
    mimeTypes = [ "text/x-java" ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit (src) url hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    gtk3
    libGL
    libdrm
    libgbm
    libnotify
    libsecret
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    libxxf86vm
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    udev
    zlib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  postPatch = ''
    # Let the IDE find libsecret, libnotify, udev and e2fsprogs at runtime
    # (same approach as the other JetBrains IDE packages in nixpkgs).
    printf '\n%s\n' "-Djna.library.path=${lib.makeLibraryPath [
      libsecret
      e2fsprogs
      libnotify
      udev
    ]}" >> bin/openide64.vmoptions
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/openide $out/bin
    cp -a . $out/opt/openide/

    makeWrapper $out/opt/openide/bin/openide $out/bin/openide \
      --prefix PATH : ${lib.makeBinPath [ coreutils git gnugrep which ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ fontconfig freetype ]} \
      --set-default LOCALE_ARCHIVE ${glibcLocales}/lib/locale/locale-archive

    install -Dm444 $out/opt/openide/bin/openide.svg \
      $out/share/icons/hicolor/scalable/apps/${pname}.svg

    install -Dm444 -t $out/share/applications ${desktopItem}/share/applications/*.desktop

    runHook postInstall
  '';

  meta = with lib; {
    description = "Java IDE based on IntelliJ IDEA (openIDE)";
    homepage = "https://openide.ru/";
    license = licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    platforms = builtins.attrNames sources;
    mainProgram = pname;
  };
}
