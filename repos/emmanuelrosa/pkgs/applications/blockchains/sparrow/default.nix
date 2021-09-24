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

let launcher = writeScript "sparrow" ''
  #! ${bash}/bin/bash

  params=(
    --module-path @out@/lib
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

  XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS /nix/store/anwva8fk7zf2ykjkzggjkg38wd7sxx39-openjdk-16+36/bin/java ''${params[@]} $@
'';

  torWrapper = writeScript "tor-wrapper" ''
    #! ${bash}/bin/bash

    exec ${tor}/bin/tor "$@"
  '';

in stdenv.mkDerivation rec {
  pname = "sparrow";
  version = "1.4.3";

  src = fetchurl {
    url = "https://github.com/sparrowwallet/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "77818bad5f7183696a4be01db1855971b43379fd049e1e3f76ee5919fcddc655";
  };

  nativeBuildInputs = [ makeWrapper copyDesktopItems imagemagick gnugrep autoPatchelfHook libv4l stdenv.cc.cc.lib gmp xorg.libX11 xorg.libXtst gtk2 gtk3 cairo glib freetype ];

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

  buildPhase = ''
    # Extract the JDK's JIMAGE and generate a list of them.
    mkdir jdk-modules
    pushd jdk-modules
    ${openjdk16}/bin/jimage extract ${openjdk16}/lib/openjdk/lib/modules
    ls | xargs -d " " -- echo > ../jdk-modules.txt
    popd

    # Extract Sparrow's JIMAGE and generate a list of them.
    mkdir sparrow-modules
    pushd sparrow-modules
    ${openjdk16}/bin/jimage extract ../lib/runtime/lib/modules
    ls | xargs -d " " -- echo > ../sparrow-modules.txt
    find . | grep "\.so$" | xargs -- chmod ugo+x
    popd

    # Generate a list of modules which exist in both the JDK and Sparrow.
    cat sparrow-modules.txt jdk-modules.txt | sort | uniq -d | tr "\n" " " > modules-to-copy.txt

    # Copy the existing JDK modules to the Sparrow modules
    pushd jdk-modules
    cp -a $(cat ../modules-to-copy.txt) ../sparrow-modules/ 
    popd
  '';

  postBuild = ''
    # Set execute bit for executables within the modules.
    chmod ugo+x sparrow-modules/com.sparrowwallet.sparrow/native/linux/x64/hwi

    # Replace the embedded Tor binary (which is in a Tar archive)
    # with one from Nixpkgs.
    cp ${torWrapper} ./tor
    tar -cJf tor.tar.xz tor
    cp tor.tar.xz sparrow-modules/netlayer.jpms/native/linux/x64/tor.tar.xz 
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r sparrow-modules/* $out/lib/
    install -D -m 777 ${launcher} $out/bin/sparrow
    substituteAllInPlace $out/bin/sparrow

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
