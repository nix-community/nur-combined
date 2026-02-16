{ lib
, stdenv
, fetchFromGitHub
, dotnet-sdk_8
, dotnetCorePackages
, zip
, imagemagick
, makeWrapper
, copyDesktopItems
, buildDotnetModule
, makeDesktopItem
, vtracer
}:

buildDotnetModule (finalAttrs: {
  pname = "stardrop";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "Floogen";
    repo = "Stardrop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CumU2wLYmT/L3hdV5I/o1j3O+sKIODW7DU+DDOefHd0=";
  };

  projectFile = "Stardrop/Stardrop.sln";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnet-sdk_8;

  dotnetFlags = [
    "-p:SelfContained=false"
    "-p:RuntimeIdentifier="
    "-p:PublishSingleFile=false"
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "stardrop";
      desktopName = "Stardrop";
      genericName = "Stardew Valley Mod Manager";
      comment = "Manage Stardew Valley mods";
      exec = "Stardrop %U";          
      icon = "stardrop";             
      categories = [ "Game" "Utility" ];
      terminal = false;
      startupNotify = true;
    })
  ];

  packNupkg = true;
  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    zip
    imagemagick
    vtracer
  ];

  postPatch = ''
    vtracer \
      --colormode color \
      --color_precision 8 \
      --filter_speckle 0 \
      --gradient_step 0 \
      --hierarchical stacked \
      --input Stardrop/Assets/icon.ico \
      --output Stardrop/Assets/stardrop.svg
  '';


  postInstall = ''
    install -Dm644 Stardrop/Assets/stardrop.svg "$out/share/icons/hicolor/scalable/apps/stardrop.svg"
  '';


  meta = {
    description = "Stardrop is an open-source, cross-platform mod manager for the game Stardew Valley";
    homepage = "https://github.com/Floogen/Stardrop";
    license = lib.licenses.gpl3Only;
    mainProgram = "stardrop";
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
})
