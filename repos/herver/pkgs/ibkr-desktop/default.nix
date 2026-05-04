{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "3.0e";
  pname = "ibkr-desktop";

  src = fetchurl {
    # Always serves the latest version; no versioned URL available
    url = "https://download2.interactivebrokers.com/installers/ntws/latest-standalone/ntws-latest-standalone-linux-x64.sh";
    hash = "sha256:12bm96s87xrvfd70ims12lvvmyyv8lncxjh2gs84jlm02i2axb5h";
    name = "${pname}-${version}-installer.sh";
  };

  # The installer requires exactly Zulu JRE 17.0.10 and rejects other versions
  jre = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/jres/linux-amd64-17.0.10.0.101-zulu-nojavafx.tar.gz";
    hash = "sha256:02zrsfmscxw1632kxwlg9k53rifp385q37xz5kj1y4cvdfgsr2j0";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkgs.patchelf
  ];

  # Libraries required by the bundled Qt 6.8.3 native .so files
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib # libstdc++
    zlib
    zstd
    glib
    dbus
    fontconfig
    freetype
    libGL
    libglvnd
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libxshmfence
    xorg.libxkbfile
    libxkbcommon
    xorg.xcbutilcursor
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    alsa-lib
    libpulseaudio
    gtk3
    cairo
    pango
    gdk-pixbuf
    atk
    nss
    nspr
    mesa
    libdrm
    expat
    krb5
    udev
  ];

  # Some bundled Qt plugins reference optional Qt modules not included
  # (Qt6OpenGLWidgets, Qt63DCore, Qt6VirtualKeyboard, etc.)
  autoPatchelfIgnoreMissingDeps = true;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    # Pre-extract and patch the JRE so it runs in the Nix sandbox
    mkdir -p patched-jre
    tar xzf ${jre} -C patched-jre
    interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
    libPath="${lib.makeLibraryPath [ pkgs.zlib pkgs.glib stdenv.cc.cc.lib ]}"
    find patched-jre -type f | while read f; do
      if patchelf --print-interpreter "$f" &>/dev/null; then
        patchelf --set-interpreter "$interpreter" "$f"
      fi
      # Patch RPATH for all ELF shared objects and executables
      if patchelf --print-rpath "$f" &>/dev/null; then
        old_rpath=$(patchelf --print-rpath "$f")
        patchelf --set-rpath "$old_rpath:$libPath" "$f" 2>/dev/null || true
      fi
    done

    cp $src installer.sh
    chmod +x installer.sh
    export INSTALL4J_JAVA_HOME_OVERRIDE="$(pwd)/patched-jre"

    # Run the install4j installer in quiet mode
    bash installer.sh -q -dir $out

    # Remove installer artifacts
    rm -f $out/uninstall $out/"IBKR Desktop.desktop"

    # Fix hardcoded build-time paths in install4j config
    # Use a placeholder that the wrapper script will replace at runtime
    substituteInPlace $out/.install4j/response.varfile \
      --replace-fail "appConfigDir=/build/ntws" "appConfigDir=@IBKR_HOME@" \
      --replace-fail '"/build/ntws"' '"@IBKR_HOME@"'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Icon
    cp $out/.install4j/ntws.png $out/share/icons/hicolor/256x256/apps/ibkr-desktop.png

    # Desktop file
    cat > $out/share/applications/ibkr-desktop.desktop <<'DESKTOP'
    [Desktop Entry]
    Type=Application
    Name=IBKR Desktop
    Exec=ibkr-desktop %U
    Icon=ibkr-desktop
    Categories=Office;Finance;
    StartupWMClass=install4j-launcher-Main
    DESKTOP

    # Extract the bundled JRE for runtime use
    mkdir -p $out/jre
    tar xzf ${jre} -C $out/jre

    # Create a launcher script that sets up a writable app directory.
    # The install4j launcher expects to write config/logs next to itself.
    cat > $out/bin/ibkr-desktop <<LAUNCHER
    #!/usr/bin/env bash
    STORE_PATH="$out"
    IBKR_HOME="\''${XDG_DATA_HOME:-\$HOME/.local/share}/ibkr-desktop"
    mkdir -p "\$IBKR_HOME"

    # Symlink read-only store contents into the writable directory
    for item in data ntws.vmoptions; do
      ln -sfn "\$STORE_PATH/\$item" "\$IBKR_HOME/\$item"
    done

    # lib/ must be a real writable directory so the app can download updated JARs.
    # Symlink each file individually; recurse into subdirs via symlinks.
    mkdir -p "\$IBKR_HOME/lib"
    for f in "\$STORE_PATH"/lib/*; do
      base=\$(basename "\$f")
      if [ -d "\$f" ]; then
        ln -sfn "\$f" "\$IBKR_HOME/lib/\$base"
      else
        ln -sfn "\$f" "\$IBKR_HOME/lib/\$base"
      fi
    done

    # Create a local .install4j with a patched response.varfile
    mkdir -p "\$IBKR_HOME/.install4j"
    for f in "\$STORE_PATH"/.install4j/*; do
      base=\$(basename "\$f")
      if [ "\$base" != "response.varfile" ]; then
        ln -sfn "\$f" "\$IBKR_HOME/.install4j/\$base"
      fi
    done
    sed "s|@IBKR_HOME@|\$IBKR_HOME|g" "\$STORE_PATH/.install4j/response.varfile" \\
      > "\$IBKR_HOME/.install4j/response.varfile"

    # Copy the launcher script so app_home resolves to the writable dir
    if [ ! -f "\$IBKR_HOME/ntws" ] || [ "\$IBKR_HOME/ntws" -ot "\$STORE_PATH/ntws" ]; then
      cp -f "\$STORE_PATH/ntws" "\$IBKR_HOME/ntws"
      chmod +x "\$IBKR_HOME/ntws"
    fi

    export INSTALL4J_JAVA_HOME_OVERRIDE="\$STORE_PATH/jre"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export FONTCONFIG_FILE="${pkgs.makeFontsConf { fontDirectories = [ ]; }}"
    export QT_QPA_PLATFORM=xcb
    export QTWEBENGINE_DISABLE_SANDBOX=1
    export LD_LIBRARY_PATH="$out/lib/qt/lib:${lib.makeLibraryPath [
      pkgs.libGL
      pkgs.vulkan-loader
      pkgs.fontconfig.lib
      pkgs.udev
    ]}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"

    cd "\$IBKR_HOME"
    exec "\$IBKR_HOME/ntws" "\$@"
    LAUNCHER
    chmod +x $out/bin/ibkr-desktop

    runHook postInstall
  '';

  meta = {
    description = "Interactive Brokers desktop trading platform (ibkr-desktop)";
    homepage = "https://www.interactivebrokers.com";
    downloadPage = "https://www.interactivebrokers.com/en/trading/ibkr-desktop.php";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ibkr-desktop";
  };
}
