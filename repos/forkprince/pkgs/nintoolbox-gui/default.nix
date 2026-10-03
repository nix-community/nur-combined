{
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  fetchurl,
  libxcb,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "nintoolbox-gui";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Graphical interface for the Nintoolbox command line tools";
    homepage = "https://github.com/quatric/nintoolbox";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = pname;
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];

      unpackPhase = ''
        runHook preUnpack
        tar xzf $src
        unzip nintoolbox-macos-universal.zip
        runHook postUnpack
      '';
    })
  else let
    desktopItem = makeDesktopItem {
      name = pname;
      desktopName = "Nintoolbox";
      genericName = "Nintendo game file toolbox";
      comment = "Graphical interface for the Nintoolbox command line tools";
      exec = pname;
      icon = pname;
      terminal = false;
      categories = [
        "Utility"
        "Development"
      ];
    };
  in
    stdenvNoCC.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
      ];

      buildInputs = [libxcb];

      desktopItems = [desktopItem];

      dontBuild = true;
      dontStrip = true;

      unpackPhase = ''
        runHook preUnpack
        tar xzf $src
        tar xzf nintoolbox-linux-x86_64.tar.gz
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        app=$out/lib/$pname
        mkdir -p $app
        cp -R nintoolbox/. $app/

        makeWrapper $app/nintoolbox $out/bin/$pname \
          --prefix PATH : "$app" \
          --prefix LD_LIBRARY_PATH : "$app:${lib.makeLibraryPath [libxcb]}"

        install -Dm644 $app/logo.png \
          $out/share/icons/hicolor/512x512/apps/$pname.png

        runHook postInstall
      '';

      postInstall = ''
        addAutoPatchelfSearchPath $out/lib/$pname
      '';
    }
