{ lib
, stdenv
, fetchFromGitHub
, wrapQtAppsHook
, extra-cmake-modules
, cmake
, file
, jdk17
, copyDesktopItems
, makeDesktopItem
, xorg
, libpulseaudio
, libGL
}:

let
  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "AfoninZ";
    repo = "MultiMC5-Cracked";
    rev = "4afe2466fd5639bf8a03bfb866c070e705420d86";
    sha256 = "sha256-CLRXatiNbPv57LwT8fbOAlcRjMNISeaM5hLgL1ARF8Q=";
  };
  description = "Cracked version of a popular Minecraft launcher";
  categories = if lib.versionAtLeast lib.version "22.05pre" then [ "Game" ] else "Game;";
in
stdenv.mkDerivation {
  inherit src;
  version = "0.6.14-custom";
  pname = "ultimmc";
  nativeBuildInputs = [
    wrapQtAppsHook
    extra-cmake-modules
    cmake
    file
    jdk17
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "ultimmc";
      desktopName = "UltimMC";
      icon = "ultimmc";
      comment = description;
      exec = "UltimMC %u";
      inherit categories;
    })
  ];
  cmakeFlags = [ "-DLauncher_LAYOUT=lin-nodeps" ];
  postInstall = let
    libpath = with xorg;
      lib.makeLibraryPath [
        libX11
        libXext
        libXcursor
        libXrandr
        libXxf86vm
        libpulseaudio
        libGL
      ];
  in ''
    # nixself/nixos-21.11 for some reason auto-wraps everything in /bin that is executable
    chmod -x $out/bin/*.so
    install -Dm0644 ${src}/notsecrets/logo.svg $out/share/icons/hicolor/scalable/apps/ultimmc.svg
    wrapProgram $out/bin/UltimMC \
      "''${qtWrapperArgs[@]}" \
      --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${libpath} \
      --prefix PATH : ${lib.makeBinPath [xorg.xrandr]} \
      --add-flags '-d "$HOME/.local/share/ultimmc"'
    rm $out/UltimMC
  '';
  meta = with lib; {
    inherit description;
    platforms = platforms.linux;
    homepage = "https://github.com/AfoninZ/MultiMC5-Cracked";
    maintainers = [] ;
    license = licenses.asl20;
  };
}
