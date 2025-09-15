{ stdenv, fetchurl, dpkg, lib, makeWrapper, symlinkJoin,
alsa-lib, atk, cairo, cups, curl, dbus, expat, fontconfig, freetype, gdk-pixbuf, glib, glibc, gnome2, gnome, gnome-keyring, gtk3, libappindicator-gtk3, libdrm, libGL, libnotify, libpulseaudio, libsecret, libv4l, libxkbcommon, mesa, nspr, nss, pango, sqlcipher, systemd, wrapGAppsHook, xdg-utils, xorg, at-spi2-atk, libuuid, at-spi2-core, libgbm }:

################################################################################
# Based on element-desktop-nightly package from AUR:
# https://aur.archlinux.org/packages/element-desktop-nightly-bin
################################################################################
let
    version = "2025091301";

    rpath = lib.makeLibraryPath [
        alsa-lib
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        cups
        curl
        dbus
        expat
        fontconfig
        freetype
        glib
        glibc
        libdrm
        libsecret
        libuuid
        mesa
        libgbm
        sqlcipher

        gnome2.GConf
        gdk-pixbuf
        gtk3
        libappindicator-gtk3

        gnome-keyring

        libnotify
        libGL
        libpulseaudio
        nspr
        nss
        pango
        stdenv.cc.cc
        systemd
        libv4l
        xdg-utils

        libxkbcommon
        xorg.libxkbfile
        xorg.libX11
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libXScrnSaver
        xorg.libxcb
    ] + ":${stdenv.cc.cc.lib}/lib64";

    src = if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchurl {
            url = "https://packages.element.io/debian/pool/main/e/element-nightly/element-nightly_${version}_amd64.deb";
           sha256 = "9eea2bef7403e8c3f4364c54a2672daedf83da70233c7236be11fdc663cae5d8"; 
        }
    else if stdenv.hostPlatform.system == "aarch64-linux" then
        fetchurl {
            url = "https://packages.element.io/debian/pool/main/e/element-nightly/element-nightly_${version}_arm64.deb";
           sha256 = "7a2e9965ffce253817a8406eaa5872975e06fd95769e6cc422520a5578ad623f"; 
        }
    else
        throw "element-desktop-nightly is not supported on ${stdenv.hostPlatform.system}";

    element-desktop-nightly-unwrapped = stdenv.mkDerivation {
        pname = "element-desktop-nightly-unwrapped";
        inherit version;
        inherit src;
        system = stdenv.hostPlatform.system;

        buildInputs = [ dpkg ];
        dontUnpack = true;

        nativeBuildInputs = [
            wrapGAppsHook
            glib
            xdg-utils
        ];
        
        installPhase = ''
            mkdir -p $out
            dpkg -x $src $out

            cp -av $out/usr/* $out
            rm -rf $out/usr
            
            mkdir -p $out/bin
            ln -s $out/opt/Element-Nightly/element-desktop-nightly $out/bin/element-desktop-nightly
        '';

        postFixup = ''
            for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* -or -name \*.node\* \) ); do
                patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
                patchelf --set-rpath ${rpath}:$out/opt/Element-Nightly $file || true
            done

            # Fix the desktop link
            substituteInPlace $out/share/applications/element-desktop-nightly.desktop \
                --replace /opt $out/opt
        '';

    };

in symlinkJoin {
    name = "element-desktop-nightly";
    paths = [ element-desktop-nightly-unwrapped ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
        # Fix for wayland and LTS nixpkgs
        wrapProgram $out/bin/element-desktop-nightly --add-flags --ozone-platform=wayland \
            --add-flags --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
            --add-flags --password-store=gnome-libsecret
    '';
    meta = with lib; {
        description = "A feature-rich client for Matrix.org (nightly unstable build)";
        homepage = "https://element.io";
        license = licenses.asl20;
        maintainers = teams.matrix.members;
        mainProgram = "element-desktop-nightly";
    };
}
