{ stdenv, pkgs, lib, fetchurl, makeDesktopItem }:

let
  appBinName = "microsoft-todo-electron";

  desktopItem = makeDesktopItem rec {
    name = appBinName;
    desktopName = "ToDo";
    genericName = desktopName;
    comment = "Microsoft ToDo wrapped in Electron";

    exec = name;
    icon = appBinName;

    type = "Application";
  };

  rpath = with pkgs;
    lib.makeLibraryPath [
      atk
      nss
      nspr
      zlib
      glib
      gtk3
      mesa
      cups
      dbus
      expat
      cairo
      pango
      libpng
      libdrm
      systemd
      alsa-lib
      freetype
      gdk-pixbuf
      fontconfig
      xorg.libXi
      xorg.libX11
      xorg.libxcb
      xorg.libXext
      stdenv.cc.cc
      at-spi2-core
      libxkbcommon
      xorg.libXrandr
      xorg.libXfixes
      xorg.libXcursor
      xorg.libXrender
      xorg.libXdamage
      xorg.libXcomposite
    ];

  src = fetchurl {
    url =
      "https://github.com/Thaumy/Microsoft-ToDo-Electron/releases/download/v1.3.2/microsoft-todo-electron-1.3.2.tar.gz";
    sha256 = "0r16d68lvxf7lirx61ka1zm5mh376h1rj8xg21k08hinwhwm7k48";
  };

in stdenv.mkDerivation rec {
  pname = "microsoft-todo-electron";
  version = "1.3.2";

  phases = [ "unpackPhase" "installPhase" ];

  unpackPhase = ''
    mkdir unzipped
    tar -xvzf ${src} -C unzipped
  '';

  installPhase = ''
    cp -r unzipped/* $out

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath ${rpath}:$out $out/${appBinName}
    # echo for debug
    echo `ldd $out/${appBinName} | grep "not found"`

    mkdir -p $out/bin
    ln -s $out/${appBinName} $out/bin/${appBinName}

    # .icns
    mkdir -p $out/share/icons
    ln -s $out/icon.png $out/share/icons/${appBinName}.png

    # .desktop
    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications

    # echo for debug
    echo "App was installed in $out"
  '';

  meta = {
    description = "Microsoft ToDo wrapped in Electron";
    homepage = "https://github.com/Thaumy/Microsoft-ToDo-Electron";
    license = lib.licenses.mit;
    maintainers = [ "thaumy" ];
    platforms = lib.platforms.linux;
  };
}
