{ stdenv
, lib
, fetchFromGitHub
, cmake
, ninja
, jdk
, ghc_filesystem
, zlib
, file
, wrapQtAppsHook
, xorg
, libpulseaudio
, openal
, qtbase
, qtwayland
, qtsvg
, glfw
, pciutils
, udev
, glxinfo
, quazip
, libGL
, flite
, addDriverRunpath
, vulkan-loader
, msaClientID ? null
, extra-cmake-modules
, qtcharts
, makeWrapper
, gamemode
, mangohud
, glfw-wayland-minecraft
, writeShellScript
}:



let
  polymc =
    let
      binpath = lib.makeBinPath ([ xorg.xrandr glxinfo pciutils ]);

      libpath = with xorg; lib.makeLibraryPath ([
        libX11
        libXext
        libXcursor
        libXrandr
        libXxf86vm
        libpulseaudio
        libGL
        vulkan-loader
        glfw
        openal
        udev
        flite
        stdenv.cc.cc.lib
      ]);

      gameLibraryPath = libpath + ":${addDriverRunpath.driverLink}/lib";


    in
    stdenv.mkDerivation rec {
      pname = "polymc" + (lib.optionalString ((lib.versions.major qtbase.version) == "5") "-qt5");
      version = "6.1";

      src = fetchFromGitHub {
        owner = "PolyMC";
        repo = "PolyMC";
        rev = version;
        sha256 = "sha256-AOy13zAWQ0CtsX9z1M+fxH7Sh/QSFy7EdQ/fD9yUYc8=";
        fetchSubmodules = true;
      };
      dontWrapQtApps = true;
      nativeBuildInputs = [
        cmake
        extra-cmake-modules
        ninja
        jdk
        wrapQtAppsHook
        file
        ghc_filesystem
      ];
      buildInputs = [
        qtbase
        qtsvg
        qtcharts
        qtwayland
        quazip
        zlib
      ];


      cmakeFlags = [
        "-GNinja"
        "-DLauncher_QT_VERSION_MAJOR=${lib.versions.major qtbase.version}"
      ]
      ++ lib.optionals (msaClientID != null) [ "-DLauncher_MSA_CLIENT_ID=${msaClientID}" ];


      postPatch = ''
        # hardcode jdk paths
        substituteInPlace launcher/java/JavaUtils.cpp \
          --replace 'scanJavaDir("/usr/lib/jvm")' 'javas.append("${jdk}/lib/openjdk/bin/java")' 
      '';

      postFixup = ''
        # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
        wrapQtApp $out/bin/polymc \
          --suffix LD_LIBRARY_PATH : "${gameLibraryPath}" \
          --suffix PATH : "${binpath}" \
          --set-default ALSOFT_DRIVERS "pulse"
      '';
      passthru = {


        wrap =
          { extraJDKs ? [ ]
          , extraPaths ? [ ]
          , extraLibs ? [ ]
          , withWaylandGLFW ? false
          , withMangohud ? true
          , withGamemode ? true
          }: stdenv.mkDerivation rec {
            pname = "${polymc.pname}-wrapped";
            version = polymc.version;
            libsPath = (lib.makeLibraryPath (extraLibs ++ lib.optional withGamemode gamemode.lib)) + lib.optionalString withMangohud "${mangohud + "/lib/mangohud"}";
            binsPath = lib.makeBinPath (extraPaths ++ lib.optional withMangohud mangohud);

            waylandPreExec = writeShellScript "waylandGLFW" ''
              if [ -n "$WAYLAND_DISPLAY" ]; then
                export LD_LIBRARY_PATH=${lib.getLib glfw-wayland-minecraft}/lib:"$LD_LIBRARY_PATH"
              fi
            '';
            src = polymc;
            nativeBuildInputs = [ makeWrapper ];
            phases = [ "installPhase" "fixupPhase" ];
            installPhase = ''
              mkdir -p $out/bin
              ln -s $src/bin/polymc $out/bin/polymc
              ln -s $src/share $out/share
            '';

            postFixup = let javaPaths = lib.makeSearchPath "bin/java" (extraJDKs); in
              ''
                wrapProgram $out/bin/polymc \
                  --suffix LD_LIBRARY_PATH : "${libsPath}" \
                  --suffix POLYMC_JAVA_PATHS : "${javaPaths}" \
                  --suffix PATH : "${binsPath}" ${lib.optionalString withWaylandGLFW ''--run ${waylandPreExec}''}
                  
              '';

            preferLocalBuild = true;
            meta = polymc.meta;

          };
      };
      meta = with lib; {
        homepage = "https://polymc.org/";
        downloadPage = "https://polymc.org/download/";
        changelog = "https://github.com/PolyMC/PolyMC/releases";
        description = "A free, open source launcher for Minecraft";
        longDescription = ''
          Allows you to have multiple, separate instances of Minecraft (each with
          their own mods, texture packs, saves, etc) and helps you manage them and
          their associated options with a simple interface.
        '';
        platforms = [ "x86_64-linux" ];
        license = licenses.gpl3Only;
      };
    };
in
polymc
