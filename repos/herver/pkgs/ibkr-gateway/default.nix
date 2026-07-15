{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "10.48.1e";
  pname = "ibkr-gateway";

  src = fetchurl {
    # Always serves the latest version; no versioned URL available
    url = "https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh";
    hash = "sha256-eRq+EllMDZyHNnaf2O5jaIYbDRprcOESdbMt7f7BZpI=";
    name = "${pname}-${version}-installer.sh";
  };

  # The installer requires exactly Zulu JRE 17.0.16 with JavaFX
  jre = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/jres/linux-amd64-17.0.16.0.101-zulu.tar.gz";
    hash = "sha256-eRq+EllMDZyHNnaf2O5jaIYbDRprcOESdbMt7f7BZpI=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkgs.patchelf
  ];

  # Libraries required by the bundled JRE (Swing/JavaFX rendering)
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib # libstdc++
    zlib
    glib
    fontconfig
    freetype
    libGL
    mesa
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    alsa-lib
    libpulseaudio
  ];

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
    rm -f $out/uninstall $out/"IB Gateway 10.47.desktop"

    # Fix hardcoded build-time paths in install4j config
    substituteInPlace $out/.install4j/response.varfile \
      --replace-fail "jtsConfigDir=/build/Jts" "jtsConfigDir=@IBGW_HOME@/Jts" \
      --replace-fail '"/build/Jts"' '"@IBGW_HOME@/Jts"'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Icon
    cp $out/.install4j/ibgateway.png $out/share/icons/hicolor/256x256/apps/ibkr-gateway.png

    # Desktop file
    cat > $out/share/applications/ibkr-gateway.desktop <<'DESKTOP'
    [Desktop Entry]
    Type=Application
    Name=IB Gateway
    Exec=ibkr-gateway %U
    Icon=ibkr-gateway
    Categories=Office;Finance;
    StartupWMClass=install4j-launcher-Main
    DESKTOP

    # Extract the bundled JRE for runtime use
    mkdir -p $out/jre
    tar xzf ${jre} -C $out/jre

    # Create a launcher script that sets up a writable app directory.
    # The install4j launcher expects to write config/logs next to itself.
    cat > $out/bin/ibkr-gateway <<LAUNCHER
    #!/usr/bin/env bash
    STORE_PATH="$out"
    IBGW_HOME="\''${XDG_DATA_HOME:-\$HOME/.local/share}/ibkr-gateway"
    mkdir -p "\$IBGW_HOME"

    # Symlink read-only store contents into the writable directory
    for item in data ibgateway.vmoptions; do
      [ -e "\$STORE_PATH/\$item" ] && ln -sfn "\$STORE_PATH/\$item" "\$IBGW_HOME/\$item"
    done

    # jars/ must be a real writable directory so the app can download updated JARs.
    mkdir -p "\$IBGW_HOME/jars"
    # Remove dangling symlinks from previous versions
    find "\$IBGW_HOME/jars" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null || true
    for f in "\$STORE_PATH"/jars/*; do
      base=\$(basename "\$f")
      ln -sfn "\$f" "\$IBGW_HOME/jars/\$base"
    done

    # Create a local .install4j with a patched response.varfile
    mkdir -p "\$IBGW_HOME/.install4j"
    for f in "\$STORE_PATH"/.install4j/*; do
      base=\$(basename "\$f")
      if [ "\$base" != "response.varfile" ]; then
        ln -sfn "\$f" "\$IBGW_HOME/.install4j/\$base"
      fi
    done
    sed "s|@IBGW_HOME@|\$IBGW_HOME|g" "\$STORE_PATH/.install4j/response.varfile" \\
      > "\$IBGW_HOME/.install4j/response.varfile"

    # Copy launcher whenever the store path changes
    if [ ! -f "\$IBGW_HOME/.store-version" ] || [ "\$(cat "\$IBGW_HOME/.store-version")" != "\$STORE_PATH" ]; then
      cp -f "\$STORE_PATH/ibgateway" "\$IBGW_HOME/ibgateway"
      chmod +x "\$IBGW_HOME/ibgateway"
      echo "\$STORE_PATH" > "\$IBGW_HOME/.store-version"
    fi

    export INSTALL4J_JAVA_HOME_OVERRIDE="\$STORE_PATH/jre"
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export FONTCONFIG_FILE="${pkgs.makeFontsConf { fontDirectories = [ ]; }}"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [
      pkgs.libGL
      pkgs.fontconfig.lib
    ]}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"

    cd "\$IBGW_HOME"
    exec "\$IBGW_HOME/ibgateway" "\$@"
    LAUNCHER
    chmod +x $out/bin/ibkr-gateway

    runHook postInstall
  '';

  passthru.etagHash = "cb0027f5e22a7a699f5d97ab55836428";

  meta = {
    description = "Interactive Brokers Gateway for automated trading";
    homepage = "https://www.interactivebrokers.com";
    downloadPage = "https://www.interactivebrokers.com/en/trading/ibgateway-latest.php";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ibkr-gateway";
  };
}
