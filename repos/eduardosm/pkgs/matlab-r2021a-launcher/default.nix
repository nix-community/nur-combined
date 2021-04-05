{ lib
, stdenv
, fetchurl
, runCommand
, buildFHSUserEnv
, makeDesktopItem
, bash
, installDir ? "/opt/matlab-r2021a"
}:

stdenv.mkDerivation rec {
  pname = "matlab-r2021a-launcher";
  version = "9.9.x";

  fhsEnv = buildFHSUserEnv {
    name = "matlab-r2021a-env";

    targetPkgs = pkgs: (with pkgs; [
      alsaLib
      atk
      cacert
      glib
      glibc
      glibcLocales
      cairo
      cups
      dbus
      fontconfig
      gdk-pixbuf
      gst_all_1.gst-plugins-base
      gst_all_1.gstreamer
      gtk3
      libselinux
      libsndfile
      libuuid
      nspr
      nss
      pam
      pango
      python27
      python38
      #tcl8_4
      procps
      tzdata
      unixODBC
      unzip
      zlib

      #gcc
      #gfortran

      udev
      ncurses
    ]) ++ (with pkgs.xorg; [
      libSM
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXft
      libXi
      libXinerama
      libXrandr
      libXrender
      libXt
      libXtst
      libXxf86vm
    ]);
  };

  desktopItem = makeDesktopItem {
    name = "matlab-r2021a";
    desktopName = "MATLAB R2021a";
    exec = "matlab-r2021a -desktop";
    icon = "matlab-r2021a";
    comment = "A high-level language for numerical computation and visualization";
    mimeType = "application/x-matlab-data;text/x-matlab;";
    categories = "Development;Education;Science;Math;IDE;";
  };

  icon = fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/2/21/Matlab_Logo.png";
    sha256 = "01f2f3i8ycphh8z6w8abyqmmyrmi2v8nwwzs7ccjgl01v3360nzc";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -d $out/bin
    ln -s "${fhsEnv}/bin/matlab-r2021a-env" $out/bin/matlab-r2021a-env

    cat <<EOF > $out/bin/matlab-r2021a
    #!${bash}/bin/sh
    ${fhsEnv}/bin/matlab-r2021a-env ${installDir}/bin/matlab "\$@"
    EOF
    chmod +x $out/bin/matlab-r2021a

    install -d $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
    install -Dm644 ${icon} $out/share/pixmaps/matlab-r2021a.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "MATLAB R2021a Launcher";
    platforms = [ "x86_64-linux" ];
  };
}
