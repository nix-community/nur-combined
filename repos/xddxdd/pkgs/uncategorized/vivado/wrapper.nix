{
  lib,
  callPackage,
  buildFHSEnv,
  makeDesktopItem,
  runtimeShell,
}:

let
  unwrapped = callPackage ./unwrapped.nix { };

  desktopItem = makeDesktopItem {
    name = "vivado";
    exec = "vivado";
    icon = "vivado";
    desktopName = "AMD Vivado";
    genericName = "AMD Vivado";
    categories = [ "Development" ];
  };
in
buildFHSEnv (finalAttrs: {
  pname = "vivado";
  inherit (unwrapped) version;
  # the FHS runner must not collide with the wrapped `vivado` launcher
  executableName = "vivado-fhs";

  targetPkgs =
    pkgs: with pkgs; [
      glib
      libice
      libsm
      libxau
      libxdmcp
      libxscrnsaver
      libudev0-shim
      util-linux
      bzip2
      brotli
      expat
      dbus
      libxtst
      libxi
      dejavu_fonts
      gnumake
      ncurses5
      ncurses
      pixman
      libpng
      libjpeg
      libxcrypt-legacy
      zlib
      libxml2
      unixodbc
      freetype
      fontconfig
      libx11
      libxext
      libxrender
      # GUI
      gtk3
      libGL
      libgcc
      xdg-utils
    ];

  profile = ''
    # the FHS ld.so.cache only carries soname entries; ncurses5's alias files
    # are symlinks to the wide build, so Vivado's dlopen("libncurses.so.5")
    # needs a directory scan to match the file name
    export LD_LIBRARY_PATH=/usr/lib64:/lib64''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
  '';

  runScript = "";

  extraInstallCommands = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/128x128/apps
    ln -s ${desktopItem}/share/applications/* $out/share/applications
    install -Dm644 ${unwrapped}/share/icons/hicolor/128x128/apps/vivado.png $out/share/icons/hicolor/128x128/apps/vivado.png

    progs_to_wrap=(
      "${unwrapped}"/${unwrapped.version}/Vivado/bin/*
      "${unwrapped}"/${unwrapped.version}/Vitis/bin/*
      "${unwrapped}"/${unwrapped.version}/Model_Composer/bin/*
      "${unwrapped}"/DocNav/bin/*
      "${unwrapped}"/DocNav/docnav
      "${unwrapped}"/xic/xic
    )

    wrapper=$out/bin/${finalAttrs.executableName}
    progs_wrapped=()
    for prog in ''${progs_to_wrap[@]}; do
        [ -f "$prog" ] || continue
        [ -x "$prog" ] || continue
        case "$(basename "$prog")" in
            *.bat|*.exe.manifest|*.exe|ldlibpath.sh|setupEnv.sh|rdiArgs.sh|setEnvAndRunCmd.sh|unsetldlibpath.sh|buildInfo.txt|qt.conf|xuninstall|loader.bat|setup-boot-loader.sh)
                continue ;;
        esac
        relname="''${prog#"${unwrapped}/"}"
        wrapped="$out/$relname"
        if [ -e "$wrapped" ]; then
            continue
        fi
        progs_wrapped+=("$wrapped")
        mkdir -p "$(dirname "$wrapped")"
        {
            echo "#!${runtimeShell}"
            echo "export QT_QPA_PLATFORM=xcb"
            echo "exec $wrapper $prog \"\$@\""
        } >> "$wrapped"
    done

    cd $out
    chmod +x ''${progs_wrapped[@]}
    for prog in ''${progs_wrapped[@]}; do
        bname="$(basename "$prog")"
        if [ -e "./bin/$bname" ]; then
            continue
        fi
        ln --symbolic --relative --target-directory ./bin "$prog"
    done
  '';

  passthru.unwrapped = unwrapped;

  meta = {
    homepage = "https://www.amd.com/en/products/software/fpga-and-adaptive-socs/vivado.html";
    description = "AMD Vivado ML Standard design suite";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = [
      {
        github = "xddxdd";
        name = "Xiaodong Dong";
      }
    ];
    mainProgram = "vivado";
  };
})
