{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "10.50.1e";
  pname = "ibkr-tws";

  src = fetchurl {
    # Offline "standalone" installer; always serves the latest version.
    # It embeds the exact Zulu JRE (with JavaFX) that TWS requires, so no
    # separate JRE download is needed (IBKR does not host it under /jres).
    url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
    hash = "sha256-HNfdQN0w3kqzn2lHaxeaBHudtwI9fb6eQUcVzuvTct8=";
    name = "${pname}-${version}-installer.sh";
  };

  # Libraries required by the bundled JRE (Swing/JavaFX/AWT rendering) and by
  # the install4j installer, which initialises java.awt.Toolkit even in quiet
  # mode and therefore needs the X11 stack at build time.
  runtimeLibs = with pkgs; [
    stdenv.cc.cc.lib # libstdc++
    zlib
    glib
    fontconfig
    freetype
    libGL
    mesa
    gtk3
    pango
    cairo
    gdk-pixbuf
    atk
    nss
    nspr
    expat
    dbus
    cups
    libxkbcommon
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXdamage
    alsa-lib
    libpulseaudio
  ];
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkgs.patchelf
  ];

  buildInputs = runtimeLibs;

  # Some bundled Qt/jxbrowser plugins reference optional modules not shipped.
  autoPatchelfIgnoreMissingDeps = true;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    libPath="${lib.makeLibraryPath runtimeLibs}"

    # Extract the installer payload to obtain the embedded JavaFX JRE (Zulu 25).
    mkdir -p extract
    INSTALL4J_TEMP="$(pwd)/extract" sh $src __i4j_extract_and_exit
    jreTar=$(echo extract/*.dir/jre.tar.gz)

    # Pre-extract and patch that JRE so it runs in the Nix sandbox; the same
    # patched tree is later installed as the runtime JRE.
    mkdir -p patched-jre
    tar xzf "$jreTar" -C patched-jre
    interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
    find patched-jre -type f | while read f; do
      if patchelf --print-interpreter "$f" &>/dev/null; then
        patchelf --set-interpreter "$interpreter" "$f"
      fi
      if patchelf --print-rpath "$f" &>/dev/null; then
        old_rpath=$(patchelf --print-rpath "$f")
        patchelf --set-rpath "$old_rpath:$libPath" "$f" 2>/dev/null || true
      fi
    done

    # Run the install4j installer in quiet mode with our patched JRE.
    # INSTALL4J_DISABLE_BUNDLED_JRE stops it from unpacking its own copy of the
    # JRE (whose ELF loader is unpatched and cannot run in the sandbox).
    export HOME="$(pwd)/home"
    mkdir -p "$HOME"
    export INSTALL4J_JAVA_HOME_OVERRIDE="$(pwd)/patched-jre"
    export INSTALL4J_DISABLE_BUNDLED_JRE=true
    export LD_LIBRARY_PATH="$libPath"
    bash $src -q -dir $out

    # Remove installer artifacts (uninstaller + versioned desktop symlink)
    rm -f $out/uninstall "$out"/*.desktop

    # Make the config directory a path relative to the (writable) install
    # directory. install4j resolves the recorded jtsConfigDir against the
    # launcher's own directory, so a plain "Jts" lands next to the launcher at
    # runtime. install4j resolves the user home via getpwuid (not $HOME), so
    # read the absolute value it recorded and rewrite every occurrence.
    jtsConfigDir=$(sed -n 's/^jtsConfigDir=//p' $out/.install4j/response.varfile)
    substituteInPlace $out/.install4j/response.varfile \
      --replace-fail "$jtsConfigDir" "Jts"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Icon
    cp $out/.install4j/tws.png $out/share/icons/hicolor/256x256/apps/ibkr-tws.png

    # Desktop file
    cat > $out/share/applications/ibkr-tws.desktop <<'DESKTOP'
    [Desktop Entry]
    Type=Application
    Name=Trader Workstation
    Exec=ibkr-tws %U
    Icon=ibkr-tws
    Categories=Office;Finance;
    StartupWMClass=install4j-launcher-Main
    DESKTOP

    # Install the embedded JRE for runtime use (autoPatchelfHook fixes it up).
    mkdir -p $out/jre
    tar xzf "$(echo extract/*.dir/jre.tar.gz)" -C $out/jre

    # Create a launcher that materialises a writable app directory. The
    # install4j launcher expects to write config/logs/jars next to itself.
    cat > $out/bin/ibkr-tws <<LAUNCHER
    #!/usr/bin/env bash
    STORE_PATH="$out"
    TWS_HOME="\''${XDG_DATA_HOME:-\$HOME/.local/share}/ibkr-tws"
    mkdir -p "\$TWS_HOME"

    # Symlink read-only store contents into the writable directory
    for item in data tws.vmoptions; do
      [ -e "\$STORE_PATH/\$item" ] && ln -sfn "\$STORE_PATH/\$item" "\$TWS_HOME/\$item"
    done

    # jars/ must be a real writable directory so the app can download updated JARs.
    mkdir -p "\$TWS_HOME/jars"
    # Remove dangling symlinks from previous versions
    find "\$TWS_HOME/jars" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true
    for f in "\$STORE_PATH"/jars/*; do
      base=\$(basename "\$f")
      ln -sfn "\$f" "\$TWS_HOME/jars/\$base"
    done

    # The install4j launcher resolves its config/.install4j against the real
    # directory of the launcher binary and only honours a writable copy when
    # those files are real (symlinks redirect it back to the read-only store).
    # So, whenever the store path changes, copy the launcher and the whole
    # .install4j tree as writable files. response.varfile already records the
    # config dir as a relative "Jts", which then resolves to "\$TWS_HOME/Jts".
    if [ ! -f "\$TWS_HOME/.store-version" ] || [ "\$(cat "\$TWS_HOME/.store-version")" != "\$STORE_PATH" ]; then
      cp -f "\$STORE_PATH/tws" "\$TWS_HOME/tws"
      chmod +x "\$TWS_HOME/tws"
      rm -rf "\$TWS_HOME/.install4j"
      cp -r "\$STORE_PATH/.install4j" "\$TWS_HOME/.install4j"
      chmod -R u+w "\$TWS_HOME/.install4j"
      echo "\$STORE_PATH" > "\$TWS_HOME/.store-version"
    fi

    export INSTALL4J_JAVA_HOME_OVERRIDE="\$STORE_PATH/jre"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export FONTCONFIG_FILE="${pkgs.makeFontsConf { fontDirectories = [ ]; }}"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [
      pkgs.libGL
      pkgs.fontconfig.lib
    ]}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"

    cd "\$TWS_HOME"
    exec "\$TWS_HOME/tws" "\$@"
    LAUNCHER
    chmod +x $out/bin/ibkr-tws

    runHook postInstall
  '';

  passthru.etagHash = "fbafba10f1541816d85ed5ae4294a416";

  meta = {
    description = "Interactive Brokers Trader Workstation (TWS) trading platform";
    homepage = "https://www.interactivebrokers.com";
    downloadPage = "https://www.interactivebrokers.com/en/trading/download-tws.php";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ibkr-tws";
  };
}
