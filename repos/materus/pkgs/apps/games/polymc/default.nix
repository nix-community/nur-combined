{ stdenv
, lib
, fetchFromGitHub
, cmake
, ninja
, jdk8
, jdk
, ghc_filesystem
, zlib
, file
, wrapQtAppsHook
, xorg
, libpulseaudio
, qtbase
, quazip
, libGL
, msaClientID ? ""
, extra-cmake-modules
, qtcharts
  # For wrapper
, makeWrapper
}:



let polymc = 
let

  libpath = with xorg; lib.makeLibraryPath ([
    libX11
    libXext
    libXcursor
    libXrandr
    libXxf86vm
    libpulseaudio
    libGL
  ]);


  gameLibraryPath = libpath + ":/run/opengl-driver/lib";


in
stdenv.mkDerivation rec {
  pname = "polymc";
  version = "6.1";

  src = fetchFromGitHub {
    owner = "PolyMC";
    repo = "PolyMC";
    rev = version;
    sha256 = "sha256-AOy13zAWQ0CtsX9z1M+fxH7Sh/QSFy7EdQ/fD9yUYc8=";
    fetchSubmodules = true;
  };
  dontWrapQtApps = true;
  nativeBuildInputs = [ cmake extra-cmake-modules ninja jdk ghc_filesystem file wrapQtAppsHook ];
  buildInputs = [ qtbase quazip zlib qtcharts ];


  cmakeFlags = [
    "-GNinja"
    "-DLauncher_QT_VERSION_MAJOR=${lib.versions.major qtbase.version}"
  ] ++ lib.optionals (msaClientID != "") [ "-DLauncher_MSA_CLIENT_ID=${msaClientID}" ];


  postPatch = ''
    # hardcode jdk paths
    substituteInPlace launcher/java/JavaUtils.cpp \
      --replace 'scanJavaDir("/usr/lib/jvm")' 'javas.append("${jdk}/lib/openjdk/bin/java")' \
      --replace 'scanJavaDir("/usr/lib32/jvm")' 'javas.append("${jdk8}/lib/openjdk/bin/java")' \
  '';

  postFixup = ''
    # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
    wrapQtApp $out/bin/polymc \
      --prefix LD_LIBRARY_PATH : "${gameLibraryPath}" \
      --prefix PATH : "${lib.makeBinPath ([ xorg.xrandr ]) }"
  '';
  passthru = {


    wrap =
      { extraJDKs ? [ ]
      , extraPaths ? [ ]
      , extraLibs ? [ ]
      }: stdenv.mkDerivation rec {
        pname = "polymc-wrapped";
        version = polymc.version;

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
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extraLibs}" \
              --prefix POLYMC_JAVA_PATHS : "${javaPaths}" \
              --prefix PATH : "${lib.makeBinPath extraPaths}"
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
