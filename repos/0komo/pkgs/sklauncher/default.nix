{
  lib,
  stdenv,
  temurin-jre-bin-21,
  xorg,
  alsa-lib,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  ...
}:
let
  requiredLibraries = lib.makeLibraryPath [
    alsa-lib
    xorg.libXxf86vm
    xorg.libX11
    xorg.libXcursor
  ];
in
stdenv.mkDerivation {
  pname = "sklauncher";
  version = "3.2.12";

  src = ./.;

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];
  buildInputs =
    [
      temurin-jre-bin-21
      alsa-lib
    ]
    ++ (with xorg; [
      libXxf86vm
      libX11
      libXcursor
    ]);

  desktopItems = [(makeDesktopItem {
    name = "sklauncher";
    desktopName = "SKLauncher";
    exec = "sklauncher";
    type = "Application";
    terminal = false;
    categories = [
      "Game"
    ];
  })];

  installPhase = ''
    runHook preInstall
  
    mkdir -p $out/{share,bin}
    install -Dm655 -t $out/share sklauncher.jar
    install -Dm755 -t $out/bin sklauncher
    wrapProgram $out/bin/sklauncher \
      --set SKLAUNCHER $out/share/sklauncher.jar \
      --set JAVA_HOME ${toString temurin-jre-bin-21} \
      --prefix LD_LIBRARY_PATH : ${requiredLibraries}

    install -Dm655 -t $out/share/icons/hicolor/scalable/apps ./sklauncher.svg

    runHook postInstall
  '';

  meta = with lib; {
    licenses = licenses.unfree;
    description = "Secure and modern Minecraft Launcher";
    homepage = "https://skmedix.pl";
    maintainers = [ ];
    platforms = platforms.all;
  };
}
