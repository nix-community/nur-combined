{
  stdenv,
  fetchurl,
  lib,
  fetchFromGitHub,
  cmake,
  ninja,
  jdk,
  ghc_filesystem,
  zlib,
  file,
  wrapQtAppsHook,
  xorg,
  libpulseaudio,
  openal,
  qtbase,
  qtwayland,
  qtsvg,
  glfw3-minecraft,
  pciutils,
  udev,
  mesa-demos,
  quazip,
  libGL,
  flite,
  tomlplusplus,
  addDriverRunpath,
  vulkan-loader,
  msaClientID ? null,
  extra-cmake-modules,
  qtcharts,
  makeWrapper,
  gamemode,
  mangohud,
  strictDrm ? false,
}:

let
  polymc =
    let
      binpath = lib.makeBinPath [
        xorg.xrandr
        mesa-demos
        pciutils
      ];
      libpath =
        with xorg;
        lib.makeLibraryPath [
          glfw3-minecraft
          libX11
          libXext
          libXcursor
          libXrandr
          libXxf86vm
          
          libGL
          vulkan-loader
          
          openal
          libpulseaudio
          udev
          flite
          stdenv.cc.cc.lib
        ];
      gameLibraryPath = libpath + ":${addDriverRunpath.driverLink}/lib";
    in
    stdenv.mkDerivation rec {
      pname = "polymc" + (lib.optionalString ((lib.versions.major qtbase.version) == "5") "-qt5");
      version = "7.0";
      patches = [
        # Fix for Qt >= 6.9.0
        (fetchurl {
          url = "https://github.com/PolyMC/PolyMC/commit/0dc124d636d76692b1e2c01050743dd87dc78a05.patch";
          hash = "sha256-ACrS7JAcLq46f8puQlfvPlRb6vk/+wuv+y1yqGQjp/I=";
        })
      ];
      
      libnbtplusplus = fetchFromGitHub {
        owner = "PolyMC";
        repo = "libnbtplusplus";
        rev = "2203af7eeb48c45398139b583615134efd8d407f";
        hash = "sha256-TvVOjkUobYJD9itQYueELJX3wmecvEdCbJ0FinW2mL4=";
      };
      
      src = fetchFromGitHub {
        owner = "PolyMC";
        repo = "PolyMC";
        rev = version;
        sha256 = "sha256-tJA/xSfqRXZK/OXbxhLNqUJU5nQGVzxgownXUMTy284=";
      };
      postUnpack = ''
        rm -rf source/libraries/libnbtplusplus
        ln -s ${libnbtplusplus} source/libraries/libnbtplusplus
      '';
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
        tomlplusplus
        zlib
      ];

      cmakeFlags = [
        "-GNinja"
        (lib.cmakeFeature "Launcher_BUILD_PLATFORM" "nixerus")
        (lib.cmakeFeature "Launcher_QT_VERSION_MAJOR" (lib.versions.major qtbase.version))
        (lib.cmakeBool "Launcher_STRICT_DRM" strictDrm)
      ] ++ lib.optionals (msaClientID != null) [ "-DLauncher_MSA_CLIENT_ID=${msaClientID}" ];

      postPatch = ''
        substituteInPlace launcher/java/JavaUtils.cpp \
          --replace 'scanJavaDir("/app/jdk");' 'scanJavaDir("/app/jdk"); javas.append("${jdk}/lib/openjdk/bin/java");' 
      '';

      postFixup = ''
        wrapQtApp $out/bin/polymc \
          --suffix LD_LIBRARY_PATH : "${gameLibraryPath}" \
          --suffix PATH : "${binpath}" \
          --set-default ALSOFT_DRIVERS "pulse"
      '';
      passthru = {

        wrap =
          {
            extraJDKs ? [ ],
            extraPaths ? [ ],
            extraLibs ? [ ],
            withMangohud ? true,
            withGamemode ? true,
          }:
          stdenv.mkDerivation rec {
            pname = "${polymc.pname}-wrapped";
            version = polymc.version;
            libsPath =
              (lib.makeLibraryPath (extraLibs ++ lib.optional withGamemode gamemode.lib))
              + lib.optionalString withMangohud ":${mangohud + "/lib/mangohud"}";
            binsPath = lib.makeBinPath (extraPaths ++ lib.optional withMangohud mangohud);

            src = polymc;
            nativeBuildInputs = [ makeWrapper ];
            phases = [
              "installPhase"
              "fixupPhase"
            ];
            installPhase = ''
              mkdir -p $out/bin
              ln -s $src/bin/polymc $out/bin/polymc
              ln -s $src/share $out/share
            '';

            postFixup =
              let
                javaPaths = lib.makeSearchPath "bin/java" extraJDKs;
              in
              ''
                wrapProgram $out/bin/polymc \
                  --prefix LD_LIBRARY_PATH : "${libsPath}" \
                  --prefix POLYMC_JAVA_PATHS : "${javaPaths}" \
                  --prefix PATH : "${binsPath}"
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
