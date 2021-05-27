{ lib, buildFHSUserEnv, fetchurl, bash, runCommand }:
let
  src = fetchurl {
    url = "file:///dev/null";
    sha256 = "1amd6f6wp4l9zzpsz6y351v4giamdicwg5lswp5azkxvq53b1q6f";
  };

  installer = buildFHSUserEnv {
    name = "batchxsetup";
    targetPkgs = pkgs:
      with pkgs; [
        bash
        ncurses5
        xlibs.libX11
        xlibs.libSM
        xlibs.libICE
        xlibs.libXi
        xlibs.libXrender
        xlibs.libXrandr
        xlibs.libXext
        freetype
        fontconfig
        zlib
        glib
      ];
    extraBuildCommands = ''
      tar -C $out -xvf ${src}
    '';
    runScript = "/Xilinx_ISE_DS_Lin_14.7_1015_1/bin/lin64/batchxsetup";
    passthru = {
      inherit src;
    };
  };

  ise-bin = runCommand "ise-bin" { 
    passthru = {
      inherit installer;
    };
  } ''
    cat <<EOF >batch.cfg
    ################################################################################
    # Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
    ################################################################################

    destination_dir=$out/opt/Xilinx

    # &Import tool preferences from previous version
    copy_preferences=Y

    # &Use multiple CPU cores for faster installation
    # Enabling this option will speed up installation but may slow down other active applications.
    use_multiple_cores=Y

    application=Acquire or Manage a License Key::0


    ################################################################
    # ISE WebPACK, uncomment this block and
    # comment all other blocks to install ISE WebPACK
    ################################################################

    package=ISE WebPACK::1
    application=setupEnv.sh::1
    application=Install Linux System Generator Info XML::1
    application=Ensure Linux System Generator Symlinks::1
    application=Install Cable Drivers::0
    EOF
    yes Y | ${installer}/bin/batchxsetup --batch batch.cfg || true
  '';
in buildFHSUserEnv {
  name = "ise";
  targetPkgs = pkgs:
    with pkgs; [
      bash
      ncurses5
      xlibs.libX11
      xlibs.libSM
      xlibs.libICE
      xlibs.libXi
      xlibs.libXrender
      xlibs.libXrandr
      xlibs.libXext
      xlibs.libXmu
      xlibs.libXcursor
      xlibs.libXft
      xlibs.libXtst
      xlibs.libXp
      xlibs.libXmu
      xlibs.libXt
      motif
      freetype
      fontconfig
      zlib
      glib
      libuuid
      gcc
    ];
  runScript = "${ise-bin}/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/ise";

  passthru = {
    inherit ise-bin;
  };

  meta = with lib; {
    license = licenses.unfree;
  };
}
