{ stdenv
, lib
, makeWrapper
, fetchurl
, makeDesktopItem
, copyDesktopItems
, autoPatchelfHook
, openjdk16
, gtk3
, gsettings-desktop-schemas
, writeScript
, bash
, imagemagick
, gnugrep
, libv4l
, gmp
, xorg
, gtk2
, cairo
, glib
, freetype
, tor
, gnutar
, zip
}:

let 
  pname = "sparrow";
  version = "1.5.1";

  src = fetchurl {
    url = "https://github.com/sparrowwallet/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "0024d176d0e7b75d9f293e485aed42d86852db34e0ce5c5554abcbf9b54a5bd9";
  };

  launcher = writeScript "sparrow" ''
    #! ${bash}/bin/bash

    params=(
      --module-path @out@/lib:@jdkModules@/modules
      --add-opens javafx.graphics/com.sun.javafx.css=org.controlsfx.controls
      --add-opens javafx.graphics/javafx.scene=org.controlsfx.controls
      --add-opens javafx.controls/com.sun.javafx.scene.control.behavior=org.controlsfx.controls
      --add-opens javafx.controls/com.sun.javafx.scene.control.inputmap=org.controlsfx.controls
      --add-opens javafx.graphics/com.sun.javafx.scene.traversal=org.controlsfx.controls
      --add-opens javafx.base/com.sun.javafx.event=org.controlsfx.controls
      --add-opens javafx.controls/javafx.scene.control.cell=com.sparrowwallet.sparrow
      --add-opens org.controlsfx.controls/impl.org.controlsfx.skin=com.sparrowwallet.sparrow
      --add-opens org.controlsfx.controls/impl.org.controlsfx.skin=javafx.fxml
      --add-opens javafx.graphics/com.sun.javafx.tk=centerdevice.nsmenufx
      --add-opens javafx.graphics/com.sun.javafx.tk.quantum=centerdevice.nsmenufx
      --add-opens javafx.graphics/com.sun.glass.ui=centerdevice.nsmenufx
      --add-opens javafx.controls/com.sun.javafx.scene.control=centerdevice.nsmenufx
      --add-opens javafx.graphics/com.sun.javafx.menu=centerdevice.nsmenufx
      --add-opens javafx.graphics/com.sun.glass.ui=com.sparrowwallet.sparrow
      --add-opens javafx.graphics/com.sun.javafx.application=com.sparrowwallet.sparrow
      --add-opens java.base/java.net=com.sparrowwallet.sparrow
      --add-opens java.base/java.io=com.google.gson
      --add-reads com.sparrowwallet.merged.module=java.desktop
      --add-reads com.sparrowwallet.merged.module=java.sql
      --add-reads com.sparrowwallet.merged.module=com.sparrowwallet.sparrow
      --add-reads com.sparrowwallet.merged.module=logback.classic
      --add-reads com.sparrowwallet.merged.module=com.fasterxml.jackson.databind
      --add-reads com.sparrowwallet.merged.module=com.fasterxml.jackson.annotation
      --add-reads com.sparrowwallet.merged.module=com.fasterxml.jackson.core
      -m com.sparrowwallet.sparrow
    )

    XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS ${openjdk16}/bin/java ''${params[@]} $@
'';

  torWrapper = writeScript "tor-wrapper" ''
    #! ${bash}/bin/bash

    exec ${tor}/bin/tor "$@"
  '';

  jdk-modules = stdenv.mkDerivation {
    name = "jdk-modules";
    nativeBuildInputs = [ openjdk16 ];
    dontUnpack = true;

    buildPhase = ''
      # Extract the JDK's JIMAGE and generate a list of modules.
      mkdir modules
      pushd modules
      jimage extract ${openjdk16}/lib/openjdk/lib/modules
      ls | xargs -d " " -- echo > ../manifest.txt
      popd
    '';

    installPhase = ''
      mkdir -p $out
      cp manifest.txt $out/
      cp -r modules/ $out/
    '';
  };

  sparrow-modules = stdenv.mkDerivation {
    pname = "sparrow-modules";
    inherit version src;
    nativeBuildInputs = [ makeWrapper copyDesktopItems imagemagick gnugrep openjdk16 autoPatchelfHook libv4l stdenv.cc.cc.lib gmp xorg.libX11 xorg.libXtst gtk2 gtk3 cairo glib freetype ];

    buildPhase = ''
      # Extract Sparrow's JIMAGE and generate a list of them.
      mkdir modules
      pushd modules
      jimage extract ../lib/runtime/lib/modules

      # Delete JDK modules
      cat ${jdk-modules}/manifest.txt | xargs -I {} -- rm -fR {}

      # Delete unneeded native libs.

      rm -fR com.sparrowwallet.merged.module/com/sun/jna/freebsd-x86-64
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/freebsd-x86
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-aarch64
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-arm
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-armel
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-mips64el
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-ppc
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-ppc64le
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-s390x
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/linux-x86
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/openbsd-x86-64
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/openbsd-x86
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/sunos-sparc
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/sunos-sparcv9
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/sunos-x86-64
      rm -fR com.sparrowwallet.merged.module/com/sun/jna/sunos-x86
      rm -fR com.github.sarxos.webcam.capture/com/github/sarxos/webcam/ds/buildin/lib/linux_armel
      rm -fR com.github.sarxos.webcam.capture/com/github/sarxos/webcam/ds/buildin/lib/linux_armhf
      rm -fR com.github.sarxos.webcam.capture/com/github/sarxos/webcam/ds/buildin/lib/linux_x86
      rm -fR com.nativelibs4java.bridj/org/bridj/lib/linux_arm32_armel
      rm -fR com.nativelibs4java.bridj/org/bridj/lib/linux_armel
      rm -fR com.nativelibs4java.bridj/org/bridj/lib/linux_armhf
      rm -fR com.nativelibs4java.bridj/org/bridj/lib/linux_x86
      rm -fR com.nativelibs4java.bridj/org/bridj/lib/sunos_x64
      rm -fR com.nativelibs4java.bridj/org/bridj/lib/sunos_x86
      rm -fR com.sparrowwallet.merged.module/linux-aarch64
      rm -fR com.sparrowwallet.merged.module/linux-arm
      rm -fR com.sparrowwallet.merged.module/linux-x86

      ls | xargs -d " " -- echo > ../manifest.txt
      find . | grep "\.so$" | xargs -- chmod ugo+x
      popd
    '';

    postBuild = ''
      # Set execute bit for executables within the modules.
      chmod ugo+x modules/com.sparrowwallet.sparrow/native/linux/x64/hwi

      # Replace the embedded Tor binary (which is in a Tar archive)
      # with one from Nixpkgs.
      cp ${torWrapper} ./tor
      tar -cJf tor.tar.xz tor
      cp tor.tar.xz modules/netlayer.jpms/native/linux/x64/tor.tar.xz 
    '';

    installPhase = ''
      mkdir -p $out
      cp manifest.txt $out/
      cp -r modules/ $out/
    '';
  };
in stdenv.mkDerivation rec {
  inherit pname version src;
  nativeBuildInputs = [ makeWrapper copyDesktopItems imagemagick ];

  desktopItems = [
    (makeDesktopItem {
      name = "Sparrow Bitcoin Wallet";
      exec = pname;
      icon = pname;
      desktopName = "Sparrow Bitcoin Wallet";
      genericName = "Bitcoin Wallet";
      categories = "Network;Finance;";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out
    ln -s ${sparrow-modules}/modules $out/lib
    install -D -m 777 ${launcher} $out/bin/sparrow
    substituteAllInPlace $out/bin/sparrow
    substituteInPlace $out/bin/sparrow --subst-var-by jdkModules ${jdk-modules}

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      convert lib/Sparrow.png -resize $size sparrow.png
      install -Dm644 -t $out/share/icons/hicolor/$size/apps ${pname}.png
    done;

    runHook postInstall
  '';

  meta = with lib; {
    description = "A modern desktop Bitcoin wallet application supporting most hardware wallets and built on common standards such as PSBT, with an emphasis on transparency and usability.";
    homepage = "https://sparrowwallet.com";
    license = licenses.asl20;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = [ "x86_64-linux" ];
  };
}
