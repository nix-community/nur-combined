{ stdenv, lib
, fetchurl, patchelf
, makeDesktopItem, copyDesktopItems
, libXxf86vm, libX11, libXext, libXtst, libXi, libXrender
, glib
, libxml2
, ffmpeg
, libGL
, freetype
, fontconfig
, gtk3
, pango
, cairo
, alsa-lib
, atk
, gdk-pixbuf
}:

let
  rSubPaths = [
    "lib/amd64/jli"
    "lib/amd64/server"
    "lib/amd64"
  ];

in

stdenv.mkDerivation rec {
  pname = "ib-tws";
  version = "10.16.1n";
  etagHash = "b6d48cb1069a94e2704c6fba25187cc1";

  src = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
    hash = "sha256-TYjl4P7gkZ0pYOnagtnEFmkyTG130z0+vcMiD5kME/0=";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "IB Trader Workstation";
      exec = pname;
      icon = pname;
      categories = [ "Office" "Finance" ];
      startupWMClass = "jclient-LoginFrame";
    })
    (makeDesktopItem {
      name = "ib-gw";
      desktopName = "IB Gateway";
      exec = "ib-gw";
      icon = pname;
      categories = [ "Office" "Finance" ];
      startupWMClass = "ibgateway-GWClient";
    })
  ];

  unpackPhase = ''
    echo "Unpacking I4J sfx sh to $PWD..."
    INSTALL4J_TEMP="$PWD" sh "$src" __i4j_extract_and_exit

    # JRE
    jrePath="$out/share/${pname}/jre"
    echo "Unpacking JRE to $jrePath..."
    mkdir -p "$jrePath"
    tar -xf "$PWD/"*.dir/jre.tar.gz -C "$jrePath/"

    echo "Patching JRE executables..."
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      "$jrePath/bin/java" "$jrePath/bin/unpack200"

    echo "Unpacking JRE pack files..."
    for f in "$jrePath/lib/"*.jar.pack "$jrePath/lib/ext/"*.jar.pack; do
      jar_file=`echo "$f" | awk '{ print substr($0,1,length($0)-5) }'`
      "$jrePath/bin/unpack200" -r "$f" "$jar_file"
      [ $? -ne 0 ] && echo "Error unpacking $f" && exit 1
    done

    echo "Unpacking TWS payload..."
    INSTALL4J_JAVA_HOME_OVERRIDE="$jrePath" sh "$src" -q -dir "$PWD/"
    '';

  installPhase = ''
      runHook preInstall

      # create main startup script
      mkdir -p "$out/bin"
      cat<<EOF > "$out/bin/${pname}"
      #!$SHELL

      # get script name
      PROG=\$(basename "\$0")

      # Load system-wide settings and per-user overrides
      IB_CONFIG_DIR="\$HOME/.\$PROG"
      JAVA_GC="-Xmx4G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70"
      JAVA_UI_FLAGS="-Dswing.aatext=TRUE -Dawt.useSystemAAFontSettings=on -Dsun.awt.nopixfmt=true -Dsun.java2d.noddraw=true -Dswing.boldMetal=false -Dsun.locale.formatasdefault=true"
      JAVA_LOCALE_FLAGS="-Dsun.locale.formatasdefault=true"
      JAVA_FLAGS="\$JAVA_GC \$JAVA_UI_FLAGS \$JAVA_LOCALE_FLAGS \$JAVA_EXTRA_FLAGS"
      [ -f "\$HOME/.config/\$PROG.conf" ] && . "\$HOME/.config/\$PROG.conf"

      CLASS="jclient.LoginFrame"
      [ "\$PROG" = "ib-gw" ] && CLASS="ibgateway.GWClient"

      cd "$out/share/${pname}/jars"
      "$out/share/${pname}/jre/bin/java" -cp \* \$JAVA_FLAGS \$CLASS \$IB_CONFIG_DIR
      EOF
      chmod u+x $out/bin/${pname}

      # create symlink for the gateway
      ln -s "${pname}" "$out/bin/ib-gw"

      # copy files
      mkdir -p $out/share/${pname}
      cp -R jars $out/share/${pname}
      install -Dm644 .install4j/tws.png $out/share/pixmaps/${pname}.png

      runHook postInstall
    '';

  dontPatchELF = true;
  dontStrip = true;

  postFixup = ''
    rpath+="''${rpath:+:}${lib.concatStringsSep ":" (map (a: "$jrePath/${a}") rSubPaths)}"

    # set all the dynamic linkers
    find $out -type f -perm -0100 \
      -exec patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$rpath" {} \;

    find $out -name "*.so" -exec patchelf --set-rpath "$rpath" {} \;
  '';

  rpath = lib.strings.makeLibraryPath libraries;

  libraries =
    [stdenv.cc stdenv.cc.libc glib libxml2 ffmpeg libGL libXxf86vm alsa-lib fontconfig
      freetype pango gtk3 cairo gdk-pixbuf atk libX11 libXext libXtst
      libXi libXrender];
      # possibly missing libgdk-x11-2.0.so.0, from gtk2? never caused any trouble though

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Trader Work Station of Interactive Brokers";
    homepage = "https://www.interactivebrokers.com";
    license = licenses.unfree;
    maintainers = lib.optionals (maintainers ? k3a) [ maintainers.k3a ];
    platforms = [ "x86_64-linux" ];
  };
}
