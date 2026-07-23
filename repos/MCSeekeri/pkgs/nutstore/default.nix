{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  python3,
  gtk3,
  glib,
  pango,
  cairo,
  gdk-pixbuf,
  atk,
  harfbuzz,
  at-spi2-core,
  gobject-introspection,
  glib-networking,
  webkitgtk_4_1,
  libappindicator,
  libXtst,
  alsa-lib,
  libnotify,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nutstore";
  version = "6.4.3";

  src = fetchurl {
    url = "https://pkg-cdn.jianguoyun.com/static/exe/installer/nutstore_linux_dist_x86_64.tar.gz";
    hash = "sha256-sG3NrWTP1joKztkNddzz8x1xPVg9qZIKlKI7tIw/2xI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gtk3 glib pango cairo gdk-pixbuf atk
    gobject-introspection harfbuzz at-spi2-core
    webkitgtk_4_1 glib-networking
    libappindicator libnotify libXtst alsa-lib
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p build
    tar xzf $src -C build
    runHook postUnpack
  '';

  sourceRoot = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/nutstore $out/bin
    cp -r . $out/libexec/nutstore/

    makeWrapper ${python3.withPackages (ps: [ ps.pygobject3 ])}/bin/python3 $out/bin/nutstore \
      --add-flags "$out/libexec/nutstore/bin/nutstore-pydaemon.py" \
      --chdir $out/libexec/nutstore \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        gtk3 glib pango cairo gdk-pixbuf atk harfbuzz
        webkitgtk_4_1 glib-networking libappindicator libnotify
      ]}" \
      --prefix GI_TYPELIB_PATH : "${lib.makeSearchPathOutput "lib" "lib/girepository-1.0" [
        gobject-introspection gtk3 pango cairo gdk-pixbuf atk glib harfbuzz
        at-spi2-core libappindicator libnotify
      ]}" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}" \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"

    runHook postInstall
  '';

  meta = {
    description = "Nutstore cloud storage client";
    homepage = "https://www.jianguoyun.com";
    license = lib.licenses.unfree;
    mainProgram = "nutstore";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
