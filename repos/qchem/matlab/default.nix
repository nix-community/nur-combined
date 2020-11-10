{ stdenv, writeShellScriptBin, buildFHSUserEnv, optpath
, slurmLic ? null, slurmLicenseWrapper
} :


let
  version = "2018a";
  runPath = if slurmLic == null
    then
      "${optpath}/matlab-${version}"
    else
      slurmLicenceWrapper {
        name = "MATLAB";
        exe = "matlab";
        license = slurmLic;
        runProg = "${optpath}/matlab-${version}/bin/matlab";
      };


in buildFHSUserEnv {
  name="matlab";

  targetPkgs = pkgs: (with pkgs;
    [ udev
      coreutils
      alsaLib
      dpkg
      gcc49
      zlib
      freetype
      glib
      zlib
      fontconfig
      openssl
      which
      ncurses
      jdk11
      pam
      dbus_glib
      dbus
      pango
      gtk2-x11
      atk
      gdk_pixbuf
      cairo
    ]) ++ (with pkgs.xorg;
    [ libX11
    libXcursor
    libXrandr
    libXext
    libSM
    libICE
    libX11
    libXrandr
    libXdamage
    libXrender
    libXfixes
    libXcomposite
    libXcursor
    libxcb
    libXi
    libXScrnSaver
    libXtst
    libXt
    libXxf86vm
    ]);
    runScript = "${runPath}/bin/matlab";
}

